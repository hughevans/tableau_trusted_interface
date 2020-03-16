require 'spec_helper'

RSpec.describe TableauTrustedInterface::Report, vcr: { cassette_name: 'success' } do
  before do
    TableauTrustedInterface.configure do |config|
      config.default_tableau_user = 'foobar'
      config.default_tableau_auth_server = 'https://example.com'
      config.default_tableau_view_server = 'https://view.example.com'
      config.default_tableau_server = 'http://fallback.example.com'
    end
  end

  subject do
    TableauTrustedInterface::Report.new(
      path: 'foo/bar',
      embed_params: { embed: 'yes', toolbar: 'no' }
    )
  end

  it 'sets #path from the path option' do
    expect(subject.path).to eql('foo/bar')
  end

  it 'sets #embed_params from the embed_params option' do
    expect(subject.embed_params.size).to eql(2)
  end

  it 'transforms the embed_params keys to have a leading colon' do
    expect(subject.embed_params.keys).to all(start_with(':'))
  end

  it 'sets #auth_server from the configuration' do
    expect(subject.auth_server).to eql('https://example.com')
  end

  it 'sets #view_server from the configuration' do
    expect(subject.view_server).to eql('https://view.example.com')
  end

  it 'sets #user from the configuration' do
    expect(subject.user).to eql('foobar')
  end

  describe '#report_url' do
    it 'expands the full address without the embed params' do
      expect(subject.report_url).to eql('https://view.example.com/trusted/MUShkl_p_RrzxTPZTp9JbY_4/views/foo/bar')
    end
  end

  describe '#report_embed_url' do
    it 'expands the full address with the embed params' do
      expect(subject.report_embed_url).to eql(
        'https://view.example.com/trusted/MUShkl_p_RrzxTPZTp9JbY_4/views/foo/bar?%3Aembed=yes&%3Atoolbar=no'
      )
    end
  end

  context 'when the auth_server, view_server and user are passed in as options', vcr: { cassette_name: 'success_org' } do
    subject { TableauTrustedInterface::Report.new(auth_server: 'http://example.org', view_server: 'http://view.example.org', user: 'baz') }

    it 'sets #auth_server from the auth_server option' do
      expect(subject.auth_server).to eql('http://example.org')
    end

    it 'sets #view_server from the view_server option' do
      expect(subject.view_server).to eql('http://view.example.org')
    end

    it 'sets #user from the user option' do
      expect(subject.user).to eql('baz')
    end
  end

  context 'when the server is not white-listed', vcr: { cassette_name: 'fail' } do
    it 'raises an exception' do
      expect { subject }.to raise_error(TableauTrustedInterface::TicketDenied)
    end
  end

  context 'when no auth_server or view_server are passed in as options, but server is', vcr: { cassette_name: 'fallback' } do
    subject { TableauTrustedInterface::Report.new(server: 'http://fallback.example.org', user: 'foobar') }

    it 'sets #auth_server from the server option' do
      expect(subject.auth_server).to eql('http://fallback.example.org')
    end

    it 'sets #view_server from the server option' do
      expect(subject.view_server).to eql('http://fallback.example.org')
    end
  end


  context 'when there is no auth_server and view_server in the configuration, but there is a server', vcr: { cassette_name: 'fallback' } do
    before do
      TableauTrustedInterface.configure do |config|
        config.default_tableau_auth_server = nil
        config.default_tableau_view_server = nil
        config.default_tableau_server = 'http://fallback.example.org'
        config.default_tableau_user = 'foobar'
      end
    end

    it 'sets #auth_server from the server in the configuration' do
      expect(subject.auth_server).to eql('http://fallback.example.org')
    end

    it 'sets #view_server from the server in the configuration' do
      expect(subject.view_server).to eql('http://fallback.example.org')
    end
  end

  context 'when there is no auth_server or server in the configuration' do
    before do
      TableauTrustedInterface.configure do |config|
        config.default_tableau_auth_server = nil
        config.default_tableau_server = nil
      end
    end

    context 'and there is no auth_server passed in as an option' do
      it 'raises an exception' do
        expect { subject }.to raise_error(TableauTrustedInterface::MissingConfiguration)
      end
    end

    context 'but an auth_server is passed in as an option', vcr: { cassette_name: 'success_org' } do
      subject { TableauTrustedInterface::Report.new(auth_server: 'http://example.org') }

      it 'sets #server from the server option' do
        expect(subject.auth_server).to eql('http://example.org')
      end
    end
  end

  context 'when there is no view_server or server in the configuration' do
    before do
      TableauTrustedInterface.configure do |config|
        config.default_tableau_auth_server = 'http://example.org'
        config.default_tableau_view_server = nil
        config.default_tableau_server = nil
      end
    end

    context 'and there is no view_server passed in as an option' do
      it 'raises an exception' do
        expect { subject }.to raise_error(TableauTrustedInterface::MissingConfiguration)
      end
    end

    context 'but a view_server is passed in as an option', vcr: { cassette_name: 'success_org' } do
      subject { TableauTrustedInterface::Report.new(view_server: 'http://view.example.org') }

      it 'sets #view_server from the server option' do
        expect(subject.view_server).to eql('http://view.example.org')
      end
    end
  end

  context 'when there is no user in the configuration' do
    before do
      TableauTrustedInterface.configure do |config|
        config.default_tableau_user = nil
      end
    end

    context 'and there is no user passed in as an option' do
      it 'raises an exception' do
        expect { subject }.to raise_error(TableauTrustedInterface::MissingConfiguration)
      end
    end

    context 'but a user is passed in as an option', vcr: { cassette_name: 'success' } do
      subject { TableauTrustedInterface::Report.new(user: 'baz') }

      it 'sets #user from the user option' do
        expect(subject.user).to eql('baz')
      end
    end
  end

  context 'when there is a socket error connecting to the server' do
    before do
      allow(RestClient).to receive(:post).and_raise(SocketError)
    end

    it 'rescues it and raises a custom exception' do
      expect { subject }.to raise_error(TableauTrustedInterface::ServerUnavailable, 'https://example.com')
    end
  end

  context 'when there is a time out error connecting to the server' do
    before do
      allow(RestClient).to receive(:post).and_raise(RestClient::RequestTimeout)
    end

    it 'rescues it and raises a custom exception' do
      expect { subject }.to raise_error(TableauTrustedInterface::ServerUnavailable, 'https://example.com')
    end
  end
end
