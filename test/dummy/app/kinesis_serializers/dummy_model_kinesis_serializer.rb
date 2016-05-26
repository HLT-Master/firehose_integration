module DummyModelKinesisSerializer
  extend ActiveSupport::Concern

  included do
    def to_kinesis
      prepare_for_redshift [
        id,
        updated_at,
        created_at
      ]
    end

    def self.kinesis_stream_name
      'dummy-stream'
    end
  end
end
