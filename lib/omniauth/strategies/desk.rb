require 'omniauth-oauth'
require 'uri'

module OmniAuth
  module Strategies
    # An omniauth 1.0 strategy for Desk.com authorization
    class Desk < OmniAuth::Strategies::OAuth
      option :name, 'desk'
      option :site, nil
      option :site_param, 'site'
      option :shared_secret, nil
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
          :level       => user_info['level'],
          :avatar      => user_info['avatar'],
          :site        => session[:site]
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      # Return info gathered from the verify_credentials API call
      def raw_info
        if access_token
          @raw_info ||= ::JSON.parse(access_token.get('/api/v2/users/me').body)
        elsif signed_request
          @raw_info ||= decode(signed_request)
        end
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # Provide the "user" portion of the raw_info
      def user_info
        @user_info ||= raw_info.nil? ? {} : raw_info
      end

      def decode(signed_request)
        hash = OmniAuth::Desk::SignedRequest.decode(
          signed_request, shared_secret: options.shared_secret
        )['context']['user']

        {
          'id' => hash['userId'],
          'name' => hash['fullName'],
          'public_name' => hash['fullName'],
          'email' => hash['email'],
          'avatar' => hash['profileThumbnailUrl'],
          'level' => hash['userType']
        }
      end

      def signed_request
        @signed_request ||= request.params['signed_request']
      end

      def identifier
        session[:site] = options.client_options.site = options.site || validate_site(request.params[options.site_param.to_s])
        session[:site] = options.client_options.site = nil if options.client_options.site == ''
        options.client_options.site
      end

      def uri?(uri)
        uri = ::URI.parse(uri)
        uri.scheme == 'https'
      end

      def validate_site(site)
        if site and site != ''
          uri?(site) ? site : "https://#{site}.desk.com"
        end
      end

      def get_identifier
        f = OmniAuth::Form.new title: 'Desk.com Authorization'
        f.text_field 'Site', options.site_param.to_s
        f.html '<p><strong>Hint:</strong> https://YOURSITE.desk.com'
        f.button 'Login'
        f.to_response
      end

      def request_phase
        identifier ? super : get_identifier
      rescue ::OAuth::Unauthorized => err
        fail!(:unathorized, err)
      end

      def callback_phase
        if signed_request.nil?
          options.client_options.site = session[:site] if session[:site]
          super
        else
          env['omniauth.auth'] = AuthHash.new({
                                    provider: name,
                                    uid: uid,
                                    info: info,
                                    extra: extra
                                  })
          call_app!
        end
      end
    end
  end
end
