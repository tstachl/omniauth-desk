require 'spec_helper'

describe OmniAuth::Strategies::Desk, :type => :strategy do
  def app
    strat = OmniAuth::Strategies::Desk
    Rack::Builder.new {
      use Rack::Session::Cookie
      use strat
      run lambda {|env| [404, {'Content-Type' => 'text/plain'}, [nil || env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  describe '/auth/desk without a site URL' do
    before do
      get '/auth/desk'
    end

    it 'should respond with OK' do
      last_response.should be_ok
    end

    it 'should respond with HTML' do
      last_response.content_type.should == 'text/html'
    end

    it 'should render an identifier URL input' do
      last_response.body.should =~ %r{<input[^>]*desk_site}
    end
  end

  describe '/auth/desk with a site name' do
    before do
      @stub_devel = stub_request(:post, "https://devel.desk.com/oauth/request_token")
                      .to_return(:status => 200, :body => 'oauth_token=&oauth_token_secret=')
      post '/auth/desk', { :desk_site => 'devel' }
    end

    it 'should have been requested' do
      @stub_devel.should have_been_requested
    end
  end

  describe '/auth/desk with a custom site name' do
    before do
      @stub_devel = stub_request(:post, "https://devel.desk.com/oauth/request_token")
                      .to_return(:status => 200, :body => 'oauth_token=&oauth_token_secret=')
      post '/auth/desk', { :desk_site => 'https://devel.desk.com' }
    end

    it 'should have been requested' do
      @stub_devel.should have_been_requested
    end
  end

  describe 'followed by /auth/desk/callback' do
    context 'successful' do
      it 'should set provider to desk'
    end

    context 'unsuccessful' do
      before do
        get '/auth/desk/callback'
      end

      it 'should be redirected to failure' do
        last_response.should be_redirect
        last_response.headers['Location'].should =~ %r{failure}
      end
    end
  end

  context 'invalid site' do

    before do
      @stub_devel = stub_request(:post, "https://devel.desk.com/oauth/request_token")
        .to_return(:status => 403, :body => 'oauth_token=&oauth_token_secret=')
      post '/auth/desk', { :desk_site => 'https://devel.desk.com' }
    end

    it 'should be redirected to failure' do
      last_response.should be_redirect
      last_response.headers['Location'].should =~ %r{failure}
    end
  end

  # context "client options" do
  #   it 'should have correct name' do
  #     subject.options.name.should eq("desk")
  #   end
  #
  #   it 'should have correct authorize path' do
  #     subject.options.client_options.authorize_path.should eq('/oauth/authorize')
  #   end
  #
  #   it 'should have correct request token path' do
  #     subject.options.client_options.request_token_path.should eq('/oauth/request_token')
  #   end
  #
  #   it 'should have correct access token path' do
  #     subject.options.client_options.access_token_path.should eq('/oauth/access_token')
  #   end
  #
  #   it 'should have an empty user_info' do
  #     subject.user_info.should eq({})
  #   end
  # end
end
