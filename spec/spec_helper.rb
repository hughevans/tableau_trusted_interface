require 'bundler/setup'
Bundler.setup

require 'tableau_trusted_interface'
require 'vcr'
require 'webmock/rspec'

TableauTrustedInterface.configure do |config|
  config.default_tableau_user = 'foobar'
  config.default_tableau_server = 'https://example.com'
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
end
