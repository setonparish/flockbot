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
        password: @password
      }
      result = post("login/password", params, json: true)
      @connected = true
    end

    def post(path, params = {}, json: false)
      response = connection.post(path) do |req|
        if json
          # payload is json object
          req.headers['Content-Type'] = 'application/json'
          req.body = params.to_json
        else
          # payload is standard form params
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.body = params
        end
      end

      response.body
    end

    def get(path, params = {})
      response = connection.get(path, params)
      response.body
    end

    def inspect
      "#<#{self.class.name} @subdomain=\"#{@subdomain}\", @email=\"#{@email}\" @connected=#{@connected}>"
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

    def url
      "https://#{@subdomain}.flocknote.com"
    end
  end
end