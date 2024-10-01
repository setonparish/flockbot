module Flockbot
  module Models
    class Dashboard
      require "nokogiri"

      def initialize(session:)
        @session = session
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

      private

      def html_document
        @html_document ||= ::Nokogiri::HTML(@session.get("dashboard"))
      end
    end
  end
end