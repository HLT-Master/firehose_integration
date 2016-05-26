module FirehoseIntegration
  class KinesisBulkJob < ActiveJob::Base
    queue_as :kinesis_events_bulk
    def perform(stream, data)
      client = Aws::Firehose::Client.new(region:'us-east-1')

      records = []
      data.each do |d|
        records << {
          data: "#{d}\n"
        }
      end

      params = {
        delivery_stream_name: stream,
        records: records
      }

      client.put_record_batch params
    end
  end
end
