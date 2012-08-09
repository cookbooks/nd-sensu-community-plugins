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

  def initialize
    super
    @core_files = []
  end

  def find_cores
    Find.find(config[:root_path]) do |path|
      if FileTest.directory?(path)
        next
      else
        if File.basename(path).match(/^core/)
          core_files << File.expand_path(path)
        end
      end
    end
  end

  def files_list
    "Found core files: " + @core_files.join(', ')
  end

  def run
    find_cores
    warning core_files if !@core_files.empty?
    ok "No core files detected."
  end

end
