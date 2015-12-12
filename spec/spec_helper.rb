require 'bundler/setup'
Bundler.setup

require 'simplecov'
require 'vcr'
require 'webmock/rspec'

SimpleCov.start

require 'tableau_trusted_interface'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.order = :random

  Kernel.srand config.seed
end
