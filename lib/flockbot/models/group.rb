module Flockbot
  module Models
    class Group
      attr_accessor :raw, :connection
      attr_accessor :id, :name, :short_name

      def initialize(json, connection)
        @raw = json
        @connection = connection

        @id = json["groupID"]
        @name = json["groupName"]
        @short_name = json["groupShortname"]
        @everyone = everyone?
      end

      def subscriber_count
        json = connection.get("group/#{id}/getSubscriberCount")
        count = json["subscriberCount"]
        @subscriber_count = Integer(count) rescue nil
      end

      def everyone?
        @everyone = (@short_name == "everyone")
      end

      def add_user(first_name:, last_name:, email: nil, mobile_phone: nil)
        params = { fname: first_name, lname: last_name, email: email, mobile_phone: mobile_phone }
        response = connection.post("/group/#{id}/addToGroupByAdmin", params)
        response["success"]
      end

      def inspect
        "#<#{self.class.name} #{to_json}>"
      end

      def to_json
        { id: @id, name: @name, short_name: @short_name, everyone?: @everyone, subscriber_count: @subscriber_count}
      end
    end
  end
end