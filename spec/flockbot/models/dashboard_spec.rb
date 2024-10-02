require "spec_helper"

RSpec.describe Flockbot::Models::Dashboard, :vcr do
  let(:session) do
    Flockbot::Session.new(
      subdomain: ENV["FLOCKNOTE_SUBDOMAIN"],
      email: ENV["FLOCKNOTE_USER_EMAIL"]
    ).tap do |s|
      s.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])
    end
  end

  let(:dashboard) { Flockbot::Models::Dashboard.new(session:) }

  context "#group_attributes" do
    it "returns an array of group attributes", aggregate_failures: true do
      expect(dashboard.group_attributes).to be_an(Array)
      expect(dashboard.group_attributes.first).to include(
        id: a_string_matching(/\w+/),
        short_name: a_string_matching(/\w+/),
        name: a_string_matching(/\w+/)
      )
    end
  end
end
