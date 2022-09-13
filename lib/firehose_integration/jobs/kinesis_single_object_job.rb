module FirehoseIntegration
  class KinesisSingleObjectJob < ActiveJob::Base
    queue_as :kinesis_events_single

    def perform(class_name, ids)
      client = Aws::Firehose::Client.new(region:'us-east-1')
      results = []
      ids.each do |id|
        object = class_name.constantize.find(id)
        data = object.to_kinesis

        streams = Array.wrap(object.class.kinesis_stream_name)

        streams.each do |stream|
          params= {
            delivery_stream_name: stream,
            record: {
              data: "#{data}\n"
            }
          }
          results << client.put_record(params)
        end
      end
      results
    end
  end
end
