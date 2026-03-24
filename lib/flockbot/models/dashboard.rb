module Flockbot
  module Models
    class Dashboard
      require "nokogiri"

      EVERYONE_GROUP_NAME = "Everyone"
      EVERYONE_GROUP_SHORT_NAME = "everyone"

      def initialize(session:)
        @session = session
      end

      def group_attributes
        legacy_group_attributes = legacy_dashboard_group_attributes
        return legacy_group_attributes if legacy_group_attributes.any?

        navigation_group_attributes
      end

      private

      def legacy_dashboard_group_attributes
        html_document.css(".group_item").filter_map do |item|
          build_group_attributes(
            id: item.attribute("data-groupid")&.value,
            short_name: item.attribute("data-shortname")&.value,
            name: item.css(".group_name")&.text
          )
        end
      end

      def navigation_group_attributes
        groups = navigation_groups.filter_map do |group|
          build_group_attributes(
            id: group["ID"],
            short_name: group["shortname"],
            name: group["name"]
          )
        end

        everyone_group = everyone_group_attributes

        if everyone_group && groups.none? { |group| group_identity(group) == group_identity(everyone_group) }
          [everyone_group, *groups]
        else
          groups
        end
      end

      def navigation_groups
        json = @session.get("navigation/groups")
        return [] unless json.is_a?(Hash)

        Array(json["groups"])
      rescue StandardError
        []
      end

      def everyone_group_attributes
        metadata = network_metadata
        return unless metadata.is_a?(Hash)

        build_group_attributes(
          id: metadata["everyoneGroupID"],
          short_name: EVERYONE_GROUP_SHORT_NAME,
          name: EVERYONE_GROUP_NAME
        )
      end

      def network_metadata
        @network_metadata ||= @session.get("network/getMetadata")
      rescue StandardError
        nil
      end

      def build_group_attributes(id:, short_name:, name:)
        return if id.nil? || short_name.to_s.strip.empty? || name.to_s.strip.empty?

        {
          id: normalize_id(id),
          short_name: short_name.to_s.strip,
          name: name.to_s.strip
        }
      end

      def normalize_id(value)
        Integer(value, exception: false) || value
      end

      def group_identity(group)
        [group[:id], group[:short_name].downcase]
      end

      def html_document
        @html_document ||= ::Nokogiri::HTML(@session.get("dashboard"))
      end
    end
  end
end
