require 'active_support/configurable'

module TableauTrustedInterface
  include ActiveSupport::Configurable

  config_accessor :default_tableau_user
  config_accessor :default_server
end
