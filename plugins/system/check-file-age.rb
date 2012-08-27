#!/usr/bin/env ruby
#
# Check the age of a file. Checks mtime, ctime or atime
# ===
#
# Copyright 2011 Needle, Inc <ops@needle.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems'
require 'sensu-plugin/check/cli'

class CheckFileAge < Sensu::Plugin::Check::CLI

    option :file_path,
        :short => '-p PATH',
        :default => '/var/log/celery/celeryd-haystack.log'

    option :age,
        :short => '-a AGE_IN_SECONDS',
        :default => 300

    option :check_type,
        :short => '-t [ctime|mtime|atime]',
        :default => 'mtime'

    def run
        case config[:check_type]
        when "ctime"
            s = File.ctime(config[:file_path]).to_i
        when "mtime"
            s = File.mtime(config[:file_path]).to_i
        when "atime"
            s = File.atime(config[:file_path]).to_i
        else
            warning "#{config[:check_type]} is not one of [ctime|mtime|atime]"
        end
        now_sec = Time.now.to_i
        if now_sec - s > config[:age]
            warning "#{config[:file_path]} is #{now_sec - s} seconds old!"
        end
        ok "#{config[:file_path]} is not old enough for you to worry about."
    end

end
