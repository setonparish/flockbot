module Flockbot
  module Models
    class Group
      attr_reader :id, :name, :short_name, :subscriber_count

      def initialize(id:, name:, short_name:, session:)
        @id = id
        @name = name
        @short_name = short_name
        @subscriber_count = nil
        @session = session
      end

      def subscriber_count(force: false)
        return @subscriber_count if !@subscriber_count.nil? && !force

        json = @session.get("group/#{id}/getSubscriberCount")
        count = json["subscriberCount"]
        @subscriber_count = Integer(count) rescue nil
      end

      def everyone?
        @short_name == "everyone"
      end

      def add_user(first_name:, last_name:, email: nil, mobile_phone: nil)
        params = { fname: first_name, lname: last_name, email: email, mobile_phone: mobile_phone }
        response = @session.post("/group/#{id}/addToGroupByAdmin", params)
        response["success"]
      end
    end
  end
end