#!/usr/bin/ruby

API_TOKEN = "xoxp-359675659414-358555366084-520597033399-5cb5c33453b458c92f4d0f150335e756"
AUTHOR = "#{`whoami`.strip}@#{`hostname`.strip}" || "Automated script"
TEXT = ARGV[0]
CHANNEL = ARGV[1] || "data-quality-reports"

if (TEXT == nil) then abort("No input") end

cmd = p %{
curl -X POST \
     -H 'Authorization: Bearer #{API_TOKEN}' \
     -H 'Content-type: application/json; charset=utf-8' \
    --data '{"text": "#{TEXT}", "channel": "##{CHANNEL}","username":"#{AUTHOR}"}' \
https://slack.com/api/chat.postMessage
}

response = `#{cmd}`
puts response
