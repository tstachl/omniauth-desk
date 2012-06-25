# OmniAuth Desk

This gem contains the Desk.com strategy for OmniAuth.

Desk.com uses the OAuth 1.0a flow, you can read about it here: http://dev.desk.com/docs/api/oauth

## How To Use It

Add the strategy to your `Gemfile`:

    gem 'omniauth-desk'

Or you can pull it directly from github eg:

    gem 'omniauth-desk', :git => 'https://github.com/tstachl/omniauth-desk.git'

For a Rails application you'd now create an initializer `config/initializers/omniauth.rb`:

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :desk, 'api_key', 'api_secret', :site => 'https://yoursite.desk.com' 
    end

For Sinatra you'd add this 4 lines:

    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :desk, 'api_key', 'api_secret', :site => 'https://yoursite.desk.com'
    end

You can find the api_key and the api_secret in your desk.com administration area. Click on Settings -> API -> My Applications.

## License

Copyright (c) 2011 by Salesforce.com, Thomas Stachl <tstachl@salesforce.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.