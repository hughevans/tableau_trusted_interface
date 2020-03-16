require 'active_support/configurable'

module TableauTrustedInterface
  include ActiveSupport::Configurable

  config_accessor :default_tableau_user
  config_accessor :default_auth_server
  config_accessor :default_view_server
  config_accessor :default_server
end
