require 'spec_helper'
require 'omniauth-basecamp'
require 'base64'

describe OmniAuth::Strategies::Basecamp do
  before :each do
    @request = double('Request')
    @request.stub(:params) { {} }
    @request.stub(:cookies) { {} }

    @client_id = '123'
    @client_secret = '53cr3tz'
    @options = {}
  end

  subject do
    args = [@client_id, @client_secret, @options].compact
    OmniAuth::Strategies::Basecamp.new(nil, *args).tap do |strategy|
      strategy.stub(:request) { @request }
    end
  end

  describe '#client' do
    it 'has correct authorize url' do
      subject.client.options[:authorize_url].should eq('/authorization/new')
    end

    it 'has correct token url' do
      subject.client.options[:token_url].should eq('/authorization/token')
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      @access_token.stub(:token)
      @access_token.stub(:expires?)
      @access_token.stub(:expires_at)
      @access_token.stub(:refresh_token)
      subject.stub(:access_token) { @access_token }
    end

    it 'returns a Hash' do
      subject.credentials.should be_a(Hash)
    end

    it 'returns the token' do
      @access_token.stub(:token) { 'I6MzRaIiwidXNlcl9pZHMiO' }
      subject.credentials['token'].should eq('I6MzRaIiwidXNlcl9pZHMiO')
    end

    it 'returns the expiry status' do
      @access_token.stub(:expires?) { true }
      subject.credentials['expires'].should eq(true)

      @access_token.stub(:expires?) { false }
      subject.credentials['expires'].should eq(false)
    end

    it 'returns the expiry timestamp' do
      @access_token.stub(:expires?) { true }
      @access_token.stub(:expires_at) { 1359624154 }
      subject.credentials['expires_at'].should eq(1359624154)
    end

    it 'returns the refresh token' do
      @access_token.stub(:expires?) { true }
      @access_token.stub(:expires_at) { 1359624154 }
      @access_token.stub(:token) { 'I6MzRaIiwidXNlcl9pZHMiO' }
      @access_token.stub(:refresh_token) { 'YyIsImFwYm9sdCI6IjQzYjN' }
      subject.credentials['refresh_token'].should eq('YyIsImFwYm9sdCI6IjQzYjN')
    end

  end
end
