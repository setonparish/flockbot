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
        dashboard.group_attributes.map do |attrs|
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

    def network_id
      @connection.nil? ? nil : @connection.network_id
    end

    def inspect
      "#<#{self.class.name} #{to_json}>"
    end

    def to_json
      { subdomain: @subdomain, email: @email, network_id: network_id, connected?: connected?}
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