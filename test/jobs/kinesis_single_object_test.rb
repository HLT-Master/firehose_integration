require 'test_helper'
require 'minitest/mock'

class KinesisSingleObjectTest < ActiveJob::TestCase

  test 'it should queue the job' do
    assert_enqueued_with(job: FirehoseIntegration::KinesisSingleObjectJob) do
      FirehoseIntegration::KinesisSingleObjectJob.perform_later("DummyModel", [DummyModel.first.id])
    end
  end

  test 'it should send data to kinesis/firehose' do
    VCR.use_cassette("kinesis_success") do
      response = FirehoseIntegration::KinesisSingleObjectJob.perform_now("DummyModel", [DummyModel.first.id])
      assert response.first.record_id.present?
    end
  end

  test 'it should fail sending data to kinesis/firehose' do
    VCR.use_cassette("kinesis_failure") do
      assert_raises(Aws::Firehose::Errors::ResourceNotFoundException) do
        FirehoseIntegration::KinesisSingleObjectJob.perform_now("DummyModel", [DummyModel.first.id])
      end
    end
  end

  test 'update_all_with_kinesis should send all objects to kinesis' do
    ids = DummyModel.all.limit(10).map(&:id)

    # First set the updated_at to be way in the past.
    ids.each do |id|
      DummyModel.find(id).update_columns(updated_at: Time.zone.now - 30.days)
    end
    DummyModel.where(id: ids).update_all_with_kinesis(updated_at: Time.now)
    ids.each do |id|
      assert_in_delta DummyModel.find(id).created_at.to_i, Time.now.to_i, 5000
    end
  end
end
