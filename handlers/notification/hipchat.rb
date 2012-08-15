#!/usr/bin/env ruby

require 'rubygems'
require 'sensu-handler'
require 'hipchat'


class HipChatNotif < Sensu::Handler

  def event_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def handle
    hipchatmsg = HipChat::Client.new(settings["hipchat"]["apikey"])
    if @event['action'].eql?("resolve")
      hipchatmsg[settings["hipchat"]["room"]].send('Sensu', "RESOLVED - [#{event_name}] - #{@event['check']['notification']} <br/> OUTPUT: #{@event['check']['output']}. <br/> SUBS: #{@event['client']['subscriptions']}", :color => 'green')
    else
      hipchatmsg[settings["hipchat"]["room"]].send('Sensu', "ALERT - [#{event_name}] - #{@event['check']['notification']} <br/> OUTPUT: #{@event['check']['output']}. <br/> SUBS: #{@event['client']['subscriptions']}", :color => 'red', :notify => true)
    end
  end

end
