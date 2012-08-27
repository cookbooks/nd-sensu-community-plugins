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
require 'set'

class CheckCores < Sensu::Plugin::Check::CLI

  option :root_path,
    :short => '-p PATH',
    :default => '/etc/sv/core'

  option :seen_cores_file,
    :short => '-s PATH',
    :default => '/etc/sensu/seen_cores.dat'

  option :core_regex,
    :short => '-r REGEX',
    :default => 'core.[0-9]+'

  def initialize
    super
    @config = config
  end

  def recorded_cores
    if File.exists?(@config[:seen_cores_file])
      File.open(@config[:seen_cores_file]) do |file|
        Marshal.load(file)
      end
    else
      Set.new
    end
  end

  def existing_cores
    cores = Dir.new(@config[:root_path]).select {|f| f.match(/#{@config[:core_regex]}/)}
    cores.to_set
  end

  def files_list
    "New core files detected: " + @new_cores.join(', ')
  end

  def run
    @new_cores = existing_cores.subtract(recorded_cores).to_a
    @file = File.open(config[:seen_cores_file], 'w')
    @file.write(Marshal.dump(existing_cores))
    @file.close
    warning files_list if !@new_cores.empty?
    ok "No core files detected."
  end
end
