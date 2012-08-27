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
            s = File.ctime(config[:log_file_path])
        when "mtime"
            s = File.mtime(config[:log_file_path])
        when "atime"
            s = File.atime(config[:log_file_path])
        else
            warning "#{config[:check_type]} is not one of [ctime|mtime|atime]"
        end
        now_sec = Time.now.to_i
        if now_sec - s > config[:log_age]
            warning "Celeryd logfile is #{s} seconds old!"
        end
        ok "Celeryd logfile is not old enough for you to worry about."
    end

end
