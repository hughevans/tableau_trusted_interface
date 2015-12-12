require File.expand_path('../lib/tableau_trusted_interface/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'tableau_trusted_interface'
  spec.version = TableauTrustedInterface::VERSION
  spec.license = 'MIT'
  spec.author = 'Hugh Evans'
  spec.email = 'hugh@hughevans.net'
  spec.date = Time.now.strftime('%Y-%m-%d')
  spec.summary = 'Wrapper for embedding Tableau workbooks using the Tableau trusted interface.'
  spec.description = <<-DESC.gsub(/^    /, '').gsub("\n", ' ')
    The Tableau trusted interface allows you to embed Tableau workbooks from a
    Tableau server in your web views, even when the user isn’t presently
    authenticated.
  DESC
  spec.require_paths = ['lib']
  spec.files = Dir['lib/**/*'] + ['README.md']
  spec.homepage = 'http://github.com/hughevans/tableau_trusted_interface'
  spec.add_development_dependency 'rspec', ['>= 3.4']
  spec.add_development_dependency 'simplecov', ['>= 0.11.1']
  spec.add_development_dependency 'vcr', ['>= 3.0']
  spec.add_development_dependency 'webmock', ['>= 1.22']
  spec.add_runtime_dependency 'activesupport', ['>= 3.0']
  spec.add_runtime_dependency 'addressable', ['>= 2.3']
  spec.add_runtime_dependency 'rest-client', ['>= 1.6']
end
