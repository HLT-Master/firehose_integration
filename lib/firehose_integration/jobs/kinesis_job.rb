class KinesisJob < ActiveJob::Base
  queue_as :kinesis_events
  def perform(stream, data)
    client = Aws::Firehose::Client.new(region:'us-east-1')

    params = {
      delivery_stream_name: stream,
      record: {
        data: "#{data}\n"
      }
    }
    client.put_record params
  end
end
