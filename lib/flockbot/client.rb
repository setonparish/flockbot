require "flockbot/connection"
require "flockbot/models/dashboard"
require "flockbot/models/group"

module Flockbot
  class Client
    def initialize(subdomain: nil, email: nil, password: nil)
      @subdomain = subdomain || Flockbot.configuration.subdomain
      @email = email || Flockbot.configuration.email
      @password = password || Flockbot.configuration.password
    end

    def dashboard
      @dashboard ||= begin
        html = connection.get("dashboard")
        Flockbot::Models::Dashboard.new(html)
      end
    end

    def groups
      @groups ||= begin
        params = { startDate: Date.today.prev_month.strftime("%Y-%m-%d"), endDate: Date.today.strftime("%Y-%m-%d"), reportType: "notesSent" }
        json = connection.post("unolytics/#{dashboard.network_id}/getReport", params)
        json["info"].map do |attrs|
          Flockbot::Models::Group.new(attrs, connection)
        end
      end
    end

    def everyone_group
      @everyone_group ||= groups.detect(&:everyone?)
    end

    def connected?
      @connection.nil? ? false : @connection.connected
    end

    def inspect
      "#<#{self.class.name} #{to_json}>"
    end

    def to_json
      { subdomain: @subdomain, email: @email, connected?: @connected}
    end


    private

    def connection
      @connection ||= begin
        Flockbot::Connection.new(subdomain: @subdomain, email: @email, password: @password).tap do |c|
          c.connect!
        end
      end
    end
  end
end