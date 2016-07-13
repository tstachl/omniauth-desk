require 'spec_helper'

describe OmniAuth::Strategies::Desk, :type => :strategy do
  def app
    strat = OmniAuth::Strategies::Desk
    Rack::Builder.new {
      use Rack::Session::Cookie, :secret => "MY_SECRET"
      use strat
      run lambda {|env| [404, {'Content-Type' => 'text/plain'}, [nil || env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  describe '/auth/desk without a site URL' do
    before do
      get '/auth/desk'
    end

    it 'should respond with OK' do
      expect(last_response)
    end

    it 'should respond with HTML' do
      expect(last_response.content_type).to eq('text/html')
    end

    it 'should render an identifier URL input' do
      expect(last_response.body).to match(/<input[^>]*desk_site/)
    end
  end

  describe '/auth/desk with a site name' do
    before do
      @stub_devel = stub_request(:post, "https://devel.desk.com/oauth/request_token")
                      .to_return(status: 200, body: 'oauth_token=&oauth_token_secret=')
      post '/auth/desk', desk_site: 'devel'
    end

    it 'should have been requested' do
      expect(@stub_devel).to have_been_requested
    end
  end

  describe '/auth/desk with a custom site name' do
    before do
      @stub_devel = stub_request(:post, "https://devel.desk.com/oauth/request_token")
                      .to_return(status: 200, body: 'oauth_token=&oauth_token_secret=')
      post '/auth/desk', desk_site: 'https://devel.desk.com'
    end

    it 'should have been requested' do
      expect(@stub_devel).to have_been_requested
    end
  end

  describe 'followed by /auth/desk/callback' do
    context 'successful' do
      before do
        stub_request(:post, "https://devel.desk.com/oauth/request_token")
          .to_return(status: 200, body: 'oauth_token=&oauth_token_secret=')

        post '/auth/desk', desk_site: 'https://devel.desk.com'

        @access_token = stub_request(:post, "https://devel.desk.com/oauth/access_token")
                          .to_return(status: 200, body: "oauth_token=6253282-eWudHldSbIaelX7swmsiHImEL4KinwaGloHANdrY&oauth_token_secret=2EEfA6BG3ly3sR3RjE0IBSnlQu4ZrUzPiYKmrkVU&user_id=6253282&screen_name=twitterapi")

        @api_request  = stub_request(:get, "https://devel.desk.com/api/v2/users/me")
                          .to_return(status: 200, body: '{"id":1,"name":"John Doe","public_name":"John Doe","email":"john@acme.com","level":"agent","created_at":"2015-05-11T14:40:01Z","updated_at":"2016-05-04T14:40:01Z","current_login_at":"2016-05-10T14:40:01Z","last_login_at":"2016-05-04T14:40:01Z","_links":{"self":{"href":"/api/v2/users/1","class":"user"},"preferences":{"href":"/api/v2/users/1/preferences","class":"user_preference"},"macros":{"href":"/api/v2/users/1/macros","class":"macro"},"filters":{"href":"/api/v2/users/1/filters","class":"filter"},"integration_urls":{"href":"/api/v2/users/1/integration_urls","class":"integration_url"},"groups":{"href":"/api/v2/users/1/groups","class":"group"},"searches":{"href":"/api/v2/users/1/searches","class":"search"}}}')

        get '/auth/desk/callback?code=aWekysIEeqM9PiT2hEfm0Cnr6MoLIfwWyRJcqOqHdF8f9INokharAS09ia7UNP6RiVScerfhc4w%3D%3D'
      end

      it 'should request the access token' do
        expect(@access_token).to have_been_requested
      end

      it 'should request the user data' do
        expect(@api_request).to have_been_requested
      end
    end

    context 'unsuccessful' do
      before do
        get '/auth/desk/callback'
      end

      it 'should be redirected to failure' do
        expect(last_response).to be_redirect
        expect(last_response.headers['Location']).to match(/failure/)
      end
    end
  end

  context 'invalid site' do
    before do
      stub_request(:post, "https://thisdoesnotexist.desk.com/oauth/request_token")
        .to_return(status: 403, body: 'oauth_token=&oauth_token_secret=')
      post '/auth/desk', desk_site: 'https://thisdoesnotexist.desk.com'
    end

    it 'should be redirected to failure' do
      expect(last_response).to be_redirect
      expect(last_response.headers['Location']).to match(/failure/)
    end
  end
end
