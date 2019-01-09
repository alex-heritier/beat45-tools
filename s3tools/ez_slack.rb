#!/usr/bin/ruby

API_TOKEN = "xoxp-359675659414-358555366084-520897707702-fcb05a318562e54a5d959ae26efe7d4d"
CHANNEL = "data-quality-reports"
AUTHOR = "#{`whoami`.strip}@#{`hostname`.strip}"

chat_text = ARGV[0]
if (chat_text == nil) then abort("No input") end

cmd = p %{
curl -X POST \
     -H 'Authorization: Bearer #{API_TOKEN}' \
     -H 'Content-type: application/json; charset=utf-8' \
    --data '{"text": "#{chat_text}", "channel": "##{CHANNEL}","username":"#{AUTHOR}"}' \
https://slack.com/api/chat.postMessage
}

`#{cmd}`
