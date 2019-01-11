#!/Users/alex/.rvm/rubies/ruby-2.5.3/bin/ruby

require_relative 'b45-messaging'

poller = Beat45::Poller.new('../aws.yml')
poller.poll_messages do |msg|
  puts msg.body
end
