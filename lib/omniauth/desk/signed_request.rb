module OmniAuth
  module Desk
    module SignedRequest
      ALGORITHM = 'HMACSHA256'.freeze
      class Error < ArgumentError; end

      class << self
        def decode(str, options = {})
          shared_secret = options[:shared_secret] || ENV['DESK_SHARED_SECRET']
          signature, envelope = str.split('.', 2)
          hash = JSON.parse(base64_decode(envelope))

          if hash['algorithm'] != ALGORITHM
            raise Error.new("Invalid algorithm, use `#{ALGORITHM}`.")
          end

          if compare_time(hash['expiresAt'])
            raise Error.new("Expired request.")
          end

          if base64_decode(signature) != hex(shared_secret, envelope).split.pack('H*')
            raise Error.new("Invalid signature.")
          end

          hash
        end

        def encode(hash, options = {})
          shared_secret = options[:shared_secret] || ENV['DESK_SHARED_SECRET']
          envelope      = base64_encode(JSON.generate(hash))
          signature     = base64_encode(hex(shared_secret, envelope).split.pack('H*'))
          signature + '.' + envelope
        end

        private

        def compare_time(str)
          Time.parse(str).to_i < Time.now.to_i
        end

        def hex(secret, data)
          OpenSSL::HMAC.hexdigest('sha256', secret, data)
        end

        def base64_decode(str)
          str += '=' * (4 - str.length.modulo(4))
          Base64.decode64(str.tr('-_', '+/'))
        end

        def base64_encode(str)
          Base64.strict_encode64(str).tr('+/', '-_').tr('=', '')
        end
      end
    end
  end
end
