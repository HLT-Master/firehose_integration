$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "firehose_integration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "firehose_integration"
  s.version     = FirehoseIntegration::VERSION
  s.authors     = ["onomojo"]
  s.email       = ["brian@onomojo.com"]
  s.homepage    = "https://github.com/onomojo/firehose_integration"
  s.summary     = "An easy way to get your data sent to Amazon Firehose"
  s.description = "An easy way to get your data sent to Amazon Firehose"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.5"
  s.add_dependency "aws-sdk", "~> 2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-spec-rails"
  s.add_development_dependency "minitest-vcr"
  s.add_development_dependency "webmock"
end
