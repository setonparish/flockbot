require "faraday"
require "faraday_middleware"
require "faraday-cookie_jar"

module Flockbot
  class Connection
    SESSION_COOKIE_NAME = "Flocknote"

    def initialize(subdomain:)
      @subdomain = subdomain
    end

    def get(path, params = {})
      response = connection.get(path, params)
      response.body
    end

    def post(path, params = {})
      response = connection.post(path, params)
      response.body
    end

    def session_token
      session_cookie = cookie_jar.cookies.detect { |cookie| cookie.name == SESSION_COOKIE_NAME }
      session_cookie&.value
    end

    def set_session_token(token)
      set_cookies(
        HTTP::Cookie.new(
          name: SESSION_COOKIE_NAME,
          value: token,
          domain: "flocknote.com",
          for_domain: true,
          path: "/",
          secure: true,
          httponly: true,
          expires: nil
        )
      )
    end

    def inspect
      "#<#{self.class.name} @subdomain=#{@subdomain} session_token=#{session_token}>"
    end

    private

    def connection
      @connection ||= begin
        Faraday.new(url) do |builder|
          builder.use :cookie_jar
          builder.request :url_encoded
          builder.response :json, content_type: "application/json"
          builder.use Flockbot::CustomErrors
        end
      end
    end

    def cookie_jar
      connection.builder.app.instance_variable_get(:@jar)
    end

    def set_cookies(cookies)
      Array(cookies).map do |cookie|
        cookie_jar.add(cookie)
      end
    end

    def url
      "https://#{@subdomain}.flocknote.com"
    end
  end
end