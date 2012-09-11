#!/usr/bin/env ruby
#
# Check if there are silenced nodes/checks that are too old
# ===
#
# Copyright 2012 Needle, Inc (ops@needle.com)
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems'
require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class CheckSilenced < Sensu::Plugin::Check::CLI

  option :time,
    :short => '-t N',
    :long => '--time N',
    :description => 'Number of seconds',
    :proc => proc {|a| a.to_i },
    :default => 0

  option :unsilence,
    :short => '-u',
    :long => '--unsilence',
    :description => 'Whether or not to unsilence the offending checks',
    :default => false,
    :proc => proc {|a| true }

  def get_stash(stashname)
    begin
      r = RestClient::Resource.new("http://localhost:4567/stash/#{stashname}", :timeout => 45)
      JSON.parse(r.get)
    rescue Errno::ECONNREFUSED
      warning 'Connection refused'
    rescue RestClient::RequestTimeout
      warning 'Connection timed out'
    rescue JSON::ParserError
      warning 'Sensu API returned invalid JSON'
    end
  end

  def get_stashes
    begin
      r = RestClient::Resource.new("http://localhost:4567/stashes", :timeout => 45)
      JSON.parse(r.get)
    rescue Errno::ECONNREFUSED
      warning 'Connection refused'
    rescue RestClient::RequestTimeout
      warning 'Connection timed out'
    rescue JSON::ParserError
      warning 'Sensu API returned invalid JSON'
    end
  end

  def delete_stash(stashname)
    begin
      r = RestClient::Resource.new("http://localhost:4567/stash/#{stashname}", :timeout => 45)
      JSON.parse(r.delete)
    rescue Errno::ECONNREFUSED
      warning 'Connection refused'
    rescue RestClient::RequestTimeout
      warning 'Connection timed out'
    rescue JSON::ParserError
      warning 'Sensu API returned invalid JSON'
    end
  end

  def get_old_stashes
    stashes = get_stashes
    now = Time.now.to_i
    stash_data = []
    stashes.each do |stashname|
      stash = get_stash(stashname)
      if now - stash['timestamp'] > @time
        stash_data.push(stashname)
      end
    end
    return stash_data
  end

  def run
    stashes = get_old_stashes
    if stashes.length > 0
      if @unsilence
        stashes.each do |stashname|
          delete_stash(stashname)
        end
        warning "#{stashes.length} stashes are older than #{@time} seconds. Cleaning up stashes: #{stashes.join(', ')}"
      else
        critical "#{stashes.length} stashes are older than #{@time} seconds. Not cleaning up stashes: #{stashes.join(', ')}"
      end
    end
    ok
  end
end
