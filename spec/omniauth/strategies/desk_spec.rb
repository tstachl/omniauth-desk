require 'spec_helper'

describe OmniAuth::Strategies::Desk do
  subject do
    OmniAuth::Strategies::Desk.new({})
  end

  context "client options" do
    it 'should have correct name' do
      subject.options.name.should eq("desk")
    end

    it 'should have correct authorize path' do
      subject.options.client_options.authorize_path.should eq('/oauth/authorize')
    end

    it 'should have correct request token path' do
      subject.options.client_options.request_token_path.should eq('/oauth/request_token')
    end

    it 'should have correct access token path' do
      subject.options.client_options.access_token_path.should eq('/oauth/access_token')
    end
  end
end