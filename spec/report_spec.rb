require 'spec_helper'

RSpec.describe TableauTrustedInterface::Report, vcr: { cassette_name: 'success' } do
  before do
    TableauTrustedInterface.configure do |config|
      config.default_tableau_user = 'foobar'
      config.default_tableau_server = 'https://example.com'
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

  it 'sets #server from the configuration' do
    expect(subject.server).to eql('https://example.com')
  end

  it 'sets #user from the configuration' do
    expect(subject.user).to eql('foobar')
  end

  describe '#report_url' do
    it 'expands the full address without the embed params' do
      expect(subject.report_url).to eql('https://example.com/trusted/MUShkl_p_RrzxTPZTp9JbY_4/views/foo/bar')
    end
  end

  describe '#report_embed_url' do
    it 'expands the full address with the embed params' do
      expect(subject.report_embed_url).to eql(
        'https://example.com/trusted/MUShkl_p_RrzxTPZTp9JbY_4/views/foo/bar?%3Aembed=yes&%3Atoolbar=no'
      )
    end
  end

  context 'when the server and user are passed in as options', vcr: { cassette_name: 'success_org' } do
    subject { TableauTrustedInterface::Report.new(server: 'http://example.org', user: 'baz') }

    it 'sets #server from the server option' do
      expect(subject.server).to eql('http://example.org')
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

  context 'when there is no server in the configuration' do
    before do
      TableauTrustedInterface.configure do |config|
        config.default_tableau_server = nil
      end
    end

    context 'and there is no server passed in as an option' do
      it 'raises an exception' do
        expect { subject }.to raise_error(TableauTrustedInterface::MissingConfiguration)
      end
    end

    context 'but a server is passed in as an option', vcr: { cassette_name: 'success_org' } do
      subject { TableauTrustedInterface::Report.new(server: 'http://example.org') }

      it 'sets #server from the server option' do
        expect(subject.server).to eql('http://example.org')
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
end
