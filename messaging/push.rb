#!/usr/bin/env ruby

require_relative 'b45-messaging'

msg = ARGV[0]
abort("No input message found.") unless msg

sender = Beat45::Sender.new('../aws.yml')
sender.send_message(msg)
