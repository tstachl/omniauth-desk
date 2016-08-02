require 'spec_helper'
require 'omniauth/desk/signed_request'
require 'securerandom'

describe OmniAuth::Desk::SignedRequest do
  let(:shared_secret) { SecureRandom.uuid.gsub('-', '') }
  let(:working) { { "expiresAt" => (Time.now + 10*60).iso8601, "algorithm" => "HMACSHA256" } }
  let(:unsupported) { working.merge({ "algorithm" => "HMACSHA512" }) }
  let(:too_old) { working.merge({ "expiresAt" => (Time.now - 1).iso8601 }) }

  it 'encodes a valid request' do
    encoded = OmniAuth::Desk::SignedRequest.encode(working, shared_secret: shared_secret)
    decoded = OmniAuth::Desk::SignedRequest.decode(encoded, shared_secret: shared_secret)
    expect(decoded).to eq(working)
  end

  it 'throws an unsupported algorithm error' do
    expect do
      encoded = OmniAuth::Desk::SignedRequest.encode(unsupported, shared_secret: shared_secret)
      OmniAuth::Desk::SignedRequest.decode(encoded, shared_secret: shared_secret)
    end.to raise_error(OmniAuth::Desk::SignedRequest::Error)
  end

  it 'throws a too old error' do
    expect do
      encoded = OmniAuth::Desk::SignedRequest.encode(too_old, shared_secret: shared_secret)
      OmniAuth::Desk::SignedRequest.decode(encoded, shared_secret: shared_secret)
    end.to raise_error(OmniAuth::Desk::SignedRequest::Error)
  end

  it 'throws an invalid signature error' do
    expect do
      encoded = OmniAuth::Desk::SignedRequest.encode(working, shared_secret: shared_secret)
      OmniAuth::Desk::SignedRequest.decode(encoded, shared_secret: SecureRandom.uuid.gsub('-', ''))
    end.to raise_error(OmniAuth::Desk::SignedRequest::Error)
  end
end
