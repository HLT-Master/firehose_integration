require 'test_helper'
require 'minitest/mock'

class KinesisJobTest < ActiveJob::TestCase

  test 'it should queue the job' do
    assert_enqueued_with(job: FirehoseIntegration::KinesisJob) do
      FirehoseIntegration::KinesisJob.perform_later('some-stream', 'some data')
    end
  end

  test 'it should send data to kinesis/firehose' do
    VCR.use_cassette("kinesis_success") do
      response = FirehoseIntegration::KinesisJob.perform_now('some-stream', 'some data')
      assert response.record_id.present?
    end
  end

  test 'it should fail sending data to kinesis/firehose' do
    VCR.use_cassette("kinesis_failure") do
      assert_raises(Aws::Firehose::Errors::ResourceNotFoundException) do
        FirehoseIntegration::KinesisJob.perform_now('invalid-stream-name', 'some data')
      end
    end
  end
end
