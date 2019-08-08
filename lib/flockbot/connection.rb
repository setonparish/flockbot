require "faraday"
require "faraday_middleware"
require "faraday-cookie_jar"

module Flockbot
  class Connection

    attr_reader :connected

    def initialize(subdomain:, email:, password:)
      @subdomain = subdomain
      @email = email
      @password = password
    end

    def connect!
      params = {
        email: @email,
        password: @password,
        stayLoggedIn: 1
      }

      response = post("login/go", params)

      if response["success"]
        @connected = true
      else
        raise Flockbot::AuthenticationError.new(response["message"])
      end
    end

    def post(url, params = {})
      response = connection.post(url, params)
      response.body
    end

    def get(url, params = {})
      response = connection.get(url, params)
      response.body
    end

    def inspect
      "#<#{self.class.name} @subdomain=\"#{@subdomain}\", @email=\"#{@email}\" @connected=#{@connected}>"
    end


    private

    def connection
      @connection ||= begin
        Faraday.new(url, request: { params_encoder: Faraday::FlatParamsEncoder }) do |builder|
          builder.use :cookie_jar
          builder.request :url_encoded
          builder.response :json, content_type: "application/json"
          builder.adapter Faraday.default_adapter
        end
      end
    end

    def url
      "https://#{@subdomain}.flocknote.com"
    end
  end
end