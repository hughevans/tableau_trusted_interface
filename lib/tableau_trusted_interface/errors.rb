module TableauTrustedInterface
  class TicketDenied < StandardError; end
  class ServerUnavailable < StandardError; end
  class MissingConfiguration < StandardError; end
end
