
module Flockbot
  class Client
    def initialize(session:)
      @session = session
    end

    def groups
      @groups ||= begin
        dashboard.group_attributes.map do |attrs|
          Flockbot::Models::Group.new(
            id: attrs[:id],
            name: attrs[:name],
            short_name: attrs[:short_name],
            session: @session
          )
        end
      end
    end

    def everyone_group
      @everyone_group ||= groups.detect(&:everyone?)
    end

    private

    def dashboard
      @dashboard ||= Flockbot::Models::Dashboard.new(session: @session)
    end
  end
end