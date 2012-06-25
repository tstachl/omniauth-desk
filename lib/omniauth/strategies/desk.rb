require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # An omniauth 1.0 strategy for Desk.com authorization
    class Desk < OmniAuth::Strategies::OAuth
      option :name, 'desk'
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
        @raw_info ||= MultiJson.decode(access_token.get('/api/v1/account/verify_credentials.json').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # Provide the "user" portion of the raw_info
      def user_info
        @user_info ||= raw_info.nil? ? {} : raw_info['user']
      end
      
      def request_phase
        options[:client_options][:site] = options[:site] if options[:site]
        super
      end

      def callback_phase
        options[:client_options][:site] = options[:site] if options[:site]
        super
      end
    end
  end
end