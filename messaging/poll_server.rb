#!/usr/bin/env ruby

require 'json'
require 'yaml'
require_relative 'b45-messaging'


CREDENTIALS_FILE = ARGV[0] || '../aws.yml'
ACTIONS_FILE = ARGV[1] || 'actions.yml'

def expand_arguments(template, data)
  data.each {|key, val| template.gsub!("@#{key}", "#{val}")}
  return template
end

def handle_action(action, data)
  template = action["run"]
  run = expand_arguments(template, data)

  puts "run: #{run}"

  cmd = "./#{run}"
  puts cmd

  #`#{cmd}`
end

actions = YAML.load_file(ACTIONS_FILE)

poller = Beat45::Poller.new(CREDENTIALS_FILE)
poller.poll_messages do |msg|
  data = JSON.parse(msg.body)

  action_label = data["action"]
  if actions.include?(action_label)
    duped_action = Marshal.load(Marshal.dump(actions[action_label]))
    handle_action(duped_action, data["data"])
  end
end
