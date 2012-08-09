#!/usr/bin/env ruby
#
# Check if any core files exist in the given path. Will traverse
# the entire directory.
# ===
#
# Copyright 2011 Needle, Inc <ops@needle.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems'
require 'sensu-plugin/check/cli'
require 'find'

class CheckCores < Sensu::Plugin::Check::CLI

  option :root_path,
    :short => '-p PATH'

  option :seen_cores_file,
    :short => '-s PATH',
    :default => '/etc/sensu/seen_cores.txt'

  def initialize
    super
    @core_files = []
    @seen_core_files = []
  end

  def find_cores
    begin
      File.open(config[:seen_cores_file], 'r') do |f|
        while line = f.gets
          @seen_core_files << line
        end
      end
    rescue
      nil
    end
    Find.find(config[:root_path]) do |path|
      if FileTest.directory?(path)
        next
      else
        if File.basename(path).match(/^core/) && !@seen_core_files.include?(File.expand_path(path))
          @core_files << File.expand_path(path)
        end
      end
    end
  end

  def files_list
    "New core files detected: " + @core_files.join(', ')
  end

  def run
    find_cores
    File.open(config[:seen_cores_file], 'a') {|f| f.write(@core_files.join('\n')) } if !@core_files.empty?
    warning files_list if !@core_files.empty?
    ok "No core files detected."
  end
end
