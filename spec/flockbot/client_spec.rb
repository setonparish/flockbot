require "spec_helper"

RSpec.describe Flockbot::Client, :vcr do
  let(:session) do
    Flockbot::Session.new(
      subdomain: ENV["FLOCKNOTE_SUBDOMAIN"],
      email: ENV["FLOCKNOTE_USER_EMAIL"]
    ).tap do |s|
      s.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])
    end
  end

  let(:client) { Flockbot::Client.new(session: session) }

  describe "#groups" do
    it "returns an array of Group objects", aggregate_failures: true do
      expect(client.groups).to be_an(Array)
      expect(client.groups.first).to be_a(Flockbot::Models::Group)
    end
  end

  describe "#everyone_group" do
    it "returns the Everyone group", aggregate_failures: true do
      expect(client.everyone_group).to be_a(Flockbot::Models::Group)
      expect(client.everyone_group.everyone?).to eq(true)
    end
  end
end
