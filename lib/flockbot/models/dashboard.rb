module Flockbot
  module Models
    class Dashboard
      require 'nokogiri'

      attr_accessor :raw

      def initialize(html)
        @raw = html
        @everyone_group_id = everyone_group_id
      end

      def everyone_group_id
        @raw.match(/data-itemid=\"(\d+)\"/)[1]
      end

      def group_attributes
        html_document.css(".group_item").map do |item|
          {
            id: item.attribute("data-groupid")&.value,
            short_name: item.attribute("data-shortname")&.value,
            name: item.css(".group_name")&.text
          }
        end
      end

      def inspect
        "#<#{self.class.name} #{to_json}>"
      end

      def to_json
        { everyone_group_id: @everyone_group_id }
      end

      private

      def html_document
        @html_document ||= ::Nokogiri::HTML(@raw)
      end
    end
  end
end