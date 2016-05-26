class DummyModel < ActiveRecord::Base # Inherit from any actual model that doesn't have Kinesis included
  firehose_integratable
end
