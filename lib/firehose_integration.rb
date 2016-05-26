require "firehose_integration/active_record_relation"

require "firehose_integration/jobs/kinesis_job"
require "firehose_integration/jobs/kinesis_bulk_job"
require "firehose_integration/jobs/kinesis_single_object_job"

require "firehose_integration/models/concerns/kinesis_event"
module FirehoseIntegration
end
