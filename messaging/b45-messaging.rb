#!/Users/alex/.rvm/rubies/ruby-2.5.3/bin/ruby

require 'aws-sdk-sqs'
require 'json'
require 'yaml'


module Beat45
  AWS_REGION = 'us-east-2'
  QUEUE_NAME = 'beat45-queue'

  module Actions
    CHANGE_VIDEO_VOLUME = 'change.video.volume'
  end

  class SQSClient
    def initialize credentials_filepath
      @client = SQSClient::get_sqs_client(credentials_filepath)
    end

    def self.get_sqs_client(credentials_filepath)
      credentials = YAML.load_file(credentials_filepath)

      sqs = Aws::SQS::Client.new(
        region: AWS_REGION,
        access_key_id: credentials[:access_key_id],
        secret_access_key: credentials[:secret_access_key]
      )
    end
  end

  class Sender < SQSClient
    def send_message message
      url = @client.get_queue_url({
        queue_name: QUEUE_NAME
      }).queue_url

      @client.send_message({
        queue_url: url,
        message_body: message,
        delay_seconds: 1
      })
    end
  end

  class Poller < SQSClient
    POLL_WAIT_TIME = 20

    def filter_duplicates(messages)
      messages
    end

    def poll_messages
      url = @client.get_queue_url({
        queue_name: QUEUE_NAME
      }).queue_url

      loop do
        # Poll AWS for messages
        msgs = @client.receive_message({
          queue_url: url,
          attribute_names: ["All"],
          wait_time_seconds: POLL_WAIT_TIME
        }).messages

        # Filter out duplicate messages
        msgs = filter_duplicates(msgs)

        # Handle messages
        msgs.each do |msg|
          yield msg

          # 'Delete' message so it isn't retrieved again
          @client.delete_message({
            queue_url: url,
            receipt_handle: msg.receipt_handle
          })
        end
      end
    end
  end
end
