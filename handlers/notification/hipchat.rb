#!/usr/bin/env ruby

require 'rubygems'
require 'sensu-handler'
require 'hipchat'


class HipChatNotif < Sensu::Handler

  def event_name
    if @event['client']['environment']
      @event['client']['name'] + '/' + @event['client']['environment'] + '/' + @event['check']['name']
    else
      @event['client']['name'] + '/' + @event['check']['name']
    end
  end

  def handle
    hipchatmsg = HipChat::Client.new(settings["hipchat"]["apikey"])
    if @event['client'].has_key?('partners')
      partners_str = "<br/>PARTNERS: #{@event['client']['partners'].join(', ')}"
    else
      partners_str = ""
    end
    if @event['action'].eql?("resolve")
      hipchatmsg[settings["hipchat"]["room"]].send('Sensu', "RESOLVED - [#{event_name}] - #{@event['check']['notification']} <br/> OUTPUT: #{@event['check']['output']} <br/> SUBS: #{@event['client']['subscriptions']} #{partners_str}", :color => 'green')
    else
      hipchatmsg[settings["hipchat"]["room"]].send('Sensu', "ALERT - [#{event_name}] - #{@event['check']['notification']} <br/> OUTPUT: #{@event['check']['output']} <br/> SUBS: #{@event['client']['subscriptions']} #{partners_str}", :color => 'red', :notify => true)
    end
  end

end
