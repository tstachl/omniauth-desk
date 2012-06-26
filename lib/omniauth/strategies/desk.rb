require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # An omniauth 1.0 strategy for Desk.com authorization
    class Desk < OmniAuth::Strategies::OAuth
      option :name, 'desk'
      option :site, nil
      option :site_param, 'desk_site'
      option :client_options, {
        :authorize_path       => '/oauth/authorize',
        :request_token_path   => '/oauth/request_token',
        :access_token_path    => '/oauth/access_token',
      }

      uid { 
        user_info['id']
      }
      
      info do 
        {
          :name        => user_info['name'],
          :name_public => user_info['name_public'],
          :email       => user_info['email'],
          :user_level  => user_info['user_level'],
          :login_count => user_info['login_count'],
          :time_zone   => user_info['time_zone']
        }
      end
            
      extra do
        {
          :raw_info => raw_info
        }
      end

      # Return info gathered from the verify_credentials API call 
      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/api/v1/account/verify_credentials.json').body) if access_token
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # Provide the "user" portion of the raw_info
      def user_info
        @user_info ||= raw_info.nil? ? {} : raw_info['user']
      end
      
      def identifier
        session[:site] = options.client_options.site = options.site || validate_site(request.params[options.site_param.to_s])
        session[:site] = options.client_options.site = nil if options.client_options.site == ''
        options.client_options.site
      end
      
      def validate_site(site)
        if site and site != ''
          "https://#{site}.desk.com"
        end
      end
      
      def get_identifier
        f = OmniAuth::Form.new :title => 'Desk.com Authorization'
        f.text_field 'Desk.com Site', options.site_param.to_s
        f.html '<p><strong>Hint:</strong> https://YOURSITE.desk.com'
        f.button 'Login'
        f.to_response
      end
      
      def request_phase
        identifier ? super : get_identifier
      end

      def callback_phase
        options.client_options.site = session[:site] if session[:site]
        super
      end
    end
  end
end