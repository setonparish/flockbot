module Flockbot
  class Connection

    attr_accessor :network_id

    def initialize
      persist_cookie
    end

    def post(url, params = {})
      response = connection.post(url, params)
      response.body
    end

    def get(url, params = {})
      response = connection.get(url, params)
      response.body
    end

    def persist_cookie
      params = {
        email: Flockbot.configuration.email,
        password: Flockbot.configuration.password,
        stayLoggedIn: 1
      }
      post("login/go", params)
    end

    def network_id
      @network_id ||= dashboard_response.match(/data-networkid=\"(\d+)\"/)[1]
    end

    def everyone_group_id
      @everyone_group_id ||= dashboard_response.match(/data-itemid=\"(\d+)\"/)[1]
    end

    def dashboard_response
      @dashboard_response ||= get("dashboard")
    end

    def connection
      @connection ||= begin
        url = "https://#{Flockbot.configuration.subdomain}.flocknote.com"

        Faraday.new(url, request: { params_encoder: Faraday::FlatParamsEncoder }) do |builder|
          builder.use :cookie_jar
          builder.request :url_encoded
          builder.response :json, content_type: "application/json"
          builder.adapter Faraday.default_adapter
        end
      end
    end

    def inspect
      {
        site: Flockbot.configuration.subdomain,
        email: Flockbot.configuration.email,
        network_id: @network_id,
        everyone_group_id: @everyone_group_id,
      }
    end
  end
end