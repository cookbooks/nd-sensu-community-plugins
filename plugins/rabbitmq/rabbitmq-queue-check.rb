#!/usr/bin/env ruby
#
# RabbitMQ Queue Metrics
# ===
#
# Copyright 2011 Sonian, Inc <chefs@sonian.net>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems'
require 'sensu-plugin/check/cli'
require 'socket'
require 'carrot-top'

class RabbitMQMessagesMonitor < Sensu::Plugin::Check::CLI

  option :host,
    :description => "RabbitMQ management API host",
    :long => "--host HOST",
    :default => "localhost"

  option :port,
    :description => "RabbitMQ management API port",
    :long => "--port PORT",
    :proc => proc {|p| p.to_i},
    :default => 55672

  option :user,
    :description => "RabbitMQ management API user",
    :long => "--user USER",
    :default => "guest"

  option :password,
    :description => "RabbitMQ management API password",
    :long => "--password PASSWORD",
    :default => "guest"

  option :messages_threshold,
    :description => "Number of messages to alert on or above",
    :long => "--messages NUMBER",
    :default => 100,
    :proc => proc {|m| m.to_i}

  option :filter,
    :description => "Queue name to check",
    :long => "--filter NAME"

  def get_rabbitmq_queues
    begin
      rabbitmq_info = CarrotTop.new(
        :host => config[:host],
        :port => config[:port],
        :user => config[:user],
        :password => config[:password]
      )
    rescue
      warning "could not get rabbitmq queue info"
    end
    rabbitmq_info.queues
  end

  def run
    timestamp = Time.now.to_i
    get_rabbitmq_queues.each do |queue|
      if config[:filter]
        unless queue['name'] == config[:filter]
          next
        end
      end
      if queue['messages'] >= config[:messages_threshold]
        warning "#{filter} queue has #{queue['messages']} messages, more than the allowed #{config[:messages_threshold]}"
      else
        ok "#{filter} queue has #{queue['messages']} messages in it"
      end
    end
    ok
  end

end
