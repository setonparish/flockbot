require "faraday"
require "faraday_middleware"
require "faraday-cookie_jar"

module Flockbot
  class Connection
    attr_reader :connected, :network_id

    def initialize(subdomain:, email:, password:)
      @subdomain = subdomain
      @email = email
      @password = password
    end

    def connect!
      # The new July 2024 Flocknote login process revolves around a custom two
      # factor auth process.  These calls _seem_ like they could be combined
      # into a single one, but that does not work.  Presumably, they are
      # establishing some kind of session state on the server to track the
      # user's progress through the login process.  Skipping any of these
      # steps will prevent a successful login.
      set_network_id
      set_first_factor_email
      login_with_password

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
      "#<#{self.class.name} @subdomain=\"#{@subdomain}\", @email=\"#{@email}\" @network_id=#{@network_id} @connected=#{@connected}>"
    end


    private

    def set_network_id
      params = {
        initialLoad: true,
        logout: false
      }
      result = post("/login/twoFactorAuth", params, json: true)
      @network_id = result["networkID"]
    end

    def set_first_factor_email
      params = {
        firstFactor: @email,
        initialLoad: false,
        networkID: @network_id
      }
      post("login/twoFactorAuth", params, json: true)
    end

    def login_with_password
      params = {
        firstFactor: @email,
        initialLoad: false,
        networkID: @network_id,
        password: @password
      }
      post("login/twoFactorAuth", params, json: true)
    end

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