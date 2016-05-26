require 'test_helper'
require 'minitest/mock'

class KinesisBulkJobTest < ActiveJob::TestCase

  test 'it should queue the job' do
    assert_enqueued_with(job: FirehoseIntegration::KinesisBulkJob) do
      FirehoseIntegration::KinesisBulkJob.perform_later('some-stream', ['some data'])
    end
  end

  test 'it should send data to kinesis/firehose' do
    VCR.use_cassette("kinesis_bulk_success") do
      response = FirehoseIntegration::KinesisBulkJob.perform_now('test-stream', ["some data","more data"])
      assert_equal 2, response.request_responses.count
    end
  end

  test 'it should fail sending data to kinesis/firehose' do
    VCR.use_cassette("kinesis_bulk_failure") do
      assert_raises(Aws::Firehose::Errors::ResourceNotFoundException) do
        FirehoseIntegration::KinesisBulkJob.perform_now('invalid-stream-name', ['some data'])
      end
    end
  end
end
