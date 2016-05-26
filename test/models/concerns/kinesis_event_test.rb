require 'test_helper'

class KinesisEventTest < ActiveSupport::TestCase
  test "should raise exception when to_kinesis is not defined" do
    exception = assert_raises(NoMethodError) { StupidModel.new.to_kinesis}
    assert_match "Model must define instance method to_kinesis", exception.message
  end

  test "should raise exception when kinesis_stream_name is not defined" do
    exception = assert_raises(NoMethodError) { StupidModel.kinesis_stream_name}
    assert_match "Model must define class method kinesis_stream_name", exception.message
  end

  test 'should escape newline characters' do
    bad_string = "something\r\n"
    assert_equal "something\\r\\n", DummyModel.new.escape_string_for_redshift(bad_string)
    assert_equal "something\r\n", bad_string
  end

  test 'should escape pipe characters' do
    assert_equal "something&verbar;more", DummyModel.new.escape_string_for_redshift("something|more")
  end

  test 'should prepare an array for redshift' do
    assert_equal "something|1|", DummyModel.new.prepare_for_redshift(["something",1,nil])
  end
end
