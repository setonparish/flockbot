module Flockbot
  module Models
    class Dashboard
      attr_accessor :raw

      def initialize(html)
        @raw = html
        @network_id = network_id
        @everyone_group_id = everyone_group_id
      end

      def network_id
        @raw.match(/data-networkid=\"(\d+)\"/)[1]
      end

      def everyone_group_id
        @raw.match(/data-itemid=\"(\d+)\"/)[1]
      end

      def inspect
        "#<#{self.class.name} @network_id=\"#{@network_id}\", @everyone_group_id=\"#{@everyone_group_id}\">"
      end
    end
  end
end