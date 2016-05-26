class KinesisSingleObjectJob < ActiveJob::Base
  queue_as :kinesis_events_single

  def perform(class_name, ids)
    client = Aws::Firehose::Client.new(region:'us-east-1')
    ret = nil
    results = []
    ids.each do |id|
      object = class_name.constantize.find(id)
      stream = object.class.kinesis_stream_name
      data = object.to_kinesis

      params = {
        delivery_stream_name: stream,
        record: {
          data: "#{data}\n"
        }
      }
      results << client.put_record(params)
    end
    results
  end
end
