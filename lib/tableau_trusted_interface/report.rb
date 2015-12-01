require 'addressable/template'
require 'rest-client'

module TableauTrustedInterface
  class Report
    attr_reader :server, :ticket, :user
    attr_accessor :embed_params, :path

    def initialize(options = {})
      @path = options.fetch(:path, nil)
      @embed_params = parse_embed_params(options.fetch(:embed_params, []))
      @user = options.fetch(:user, TableauTrustedInterface.config.default_tableau_user)
      @server = options.fetch(:server, TableauTrustedInterface.config.default_tableau_server)

      @ticket = generate_ticket
      raise TicketDenied, 'Check Tableau IP white-listing or user access' if @ticket == '-1'
    end

    def report_url
      report.expand(query: nil).to_s
    end

    def report_embed_url
      report.expand(query: embed_params).to_s
    end

    private

    def parse_embed_params(params)
      Hash[params.map { |key, value| [":#{key}", value] }]
    end

    def generate_ticket
      raise MissingConfiguration unless user && server
      RestClient.post(URI.join(server, 'trusted').to_s, username: user)
    rescue SocketError, RestClient::RequestTimeout
      raise ServerUnavailable, server
    end

    def report
      address.partial_expand(
        scheme: URI.parse(server).scheme,
        host: URI.parse(server).host,
        segments: ['trusted', ticket, 'views'],
        report_path: path
      )
    end

    def address
      Addressable::Template.new('{scheme}://{host}{/segments*}/{+report_path}{?query*}')
    end
  end
end
