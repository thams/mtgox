require 'faraday'
require 'faraday/request/url_encoded'
require 'faraday/response/raise_error'
require 'faraday/response/raise_mtgox_error'
require 'mtgox/response/parse_json'
require 'mtgox/version'

module MtGox
  module Connection
    private

    def connection(method)
      options = {
          headers: {
              accept: 'application/json',
              user_agent: "mtgox gem #{MtGox::Version}",
          },
          # data.mtgox.com is needed for the unauthenticated calls
          # It works with authenticated calls, but that is not what is recommended per
          # https://bitcointalk.org/index.php?topic=150786.0
          # mtgox.com should probably be used for authenticated calls
          url:
              case method
                when :get
                  'https://data.mtgox.com'
                when :post
                  'https://mtgox.com'
              end
      }

      Faraday.new(options) do |connection|
        connection.request :url_encoded
        connection.use Faraday::Response::RaiseError
        connection.use MtGox::Response::ParseJson
        connection.use Faraday::Response::RaiseMtGoxError
        connection.adapter(Faraday.default_adapter)
      end
    end
  end
end
