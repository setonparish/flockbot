require "forwardable"

module Flockbot
  class Session
    extend Forwardable

    def_delegator :@connection, :get
    def_delegator :@connection, :post
    def_delegator :@connection, :session_token
    def_delegator :@connection, :set_session_token

    def initialize(subdomain:, email:)
      @subdomain = subdomain
      @email = email
      @connection = Flockbot::Connection.new(subdomain:)
    end

    def login!(**args)
      login(**args)

      if logged_in?
        true
      else
        raise SessionLoginError, "Unable to login"
      end
    end

    def logged_in?
      json = get("user/userData")
      !!json["userID"]
    end

    def send_one_time_code
      params = {
        firstFactor: @email,
        initialLoad: false,
        requestAuthCode: true
      }
      json = post("login/twoFactorAuth", params)
      json["success"] && !!json["networkID"]
    end

    private

    def login(**args)
      if token = args[:token]
        set_session_token(token)
      elsif password = args[:password]
        authenticate_with_password(password)
      elsif code = args[:code]
        authenticate_with_one_time_code(code)
      else
        raise ArgumentError,
          "Must provide either a session :token, user :password, or one-time :code"
      end
    end

    def authenticate_with_password(password)
      # set first factor as email
      params = {
        firstFactor: @email,
        initialLoad: false,
        requestAuthCode: false
      }
      post("login/twoFactorAuth", params)

      # login with password
      params = {
        firstFactor: @email,
        initialLoad: false,
        password: password
      }
      post("login/twoFactorAuth", params)
    end

    def authenticate_with_one_time_code(code)
      params = {
        firstFactor: @email,
        firstCode: code,
        initialLoad: false
      }

      # this attempt will fail, but it will set the session
      # without triggering an additional code being sent
      post("login/twoFactorAuth", params)

      post("login/twoFactorAuth", params)
    end
  end
end