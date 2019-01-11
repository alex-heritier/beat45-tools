#!/Users/alex/.rvm/rubies/ruby-2.5.3/bin/ruby

require 'aws-sdk-sqs'
require 'yaml'

QUEUE_NAME = "beat45-queue"
POLL_WAIT_TIME = 20


def filter_duplicates(messages)
  messages
end

def handle_message(message)
  puts message.body
end

credentials = YAML.load_file('../aws.yml')

sqs = Aws::SQS::Client.new(
  region: 'us-east-2',
  access_key_id: credentials[:access_key_id],
  secret_access_key: credentials[:secret_access_key]
)

url = sqs.get_queue_url({
  queue_name: QUEUE_NAME
}).queue_url

loop do
  # Poll AWS for messages
  msgs = sqs.receive_message({
    queue_url: url,
    attribute_names: ["All"],
    wait_time_seconds: POLL_WAIT_TIME
  }).messages

  # Filter out duplicate messages
  msgs = filter_duplicates(msgs)

  # Handle messages
  msgs.each do |msg|
    handle_message(msg)

    # 'Delete' message so it isn't retrieved again
    sqs.delete_message({
      queue_url: url,
      receipt_handle: msg.receipt_handle
    })
  end
end
