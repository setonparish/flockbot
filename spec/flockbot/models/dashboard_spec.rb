require "spec_helper"

RSpec.describe Flockbot::Models::Dashboard do
  describe "#group_attributes" do
    context "when the dashboard still contains legacy group markup" do
      let(:session) { instance_double(Flockbot::Session) }
      let(:dashboard) { described_class.new(session:) }

      before do
        allow(session).to receive(:get).with("dashboard").and_return(<<~HTML)
          <html>
            <body>
              <div class="group_item" data-groupid="931283" data-shortname="everyone">
                <span class="group_name">Everyone</span>
              </div>
              <div class="group_item" data-groupid="931288" data-shortname="test">
                <span class="group_name">Aaron's Test Group</span>
              </div>
            </body>
          </html>
        HTML
      end

      it "parses groups from the dashboard HTML", aggregate_failures: true do
        expect(dashboard.group_attributes).to eq(
          [
            { id: 931283, short_name: "everyone", name: "Everyone" },
            { id: 931288, short_name: "test", name: "Aaron's Test Group" }
          ]
        )
      end
    end

    context "when groups are loaded from the navigation endpoint" do
      let(:session) { instance_double(Flockbot::Session) }
      let(:dashboard) { described_class.new(session:) }

      before do
        allow(session).to receive(:get).with("dashboard").and_return("<html><body><div id='fnReactHolder'></div></body></html>")
        allow(session).to receive(:get).with("navigation/groups").and_return(
          {
            "groups" => [
              { "ID" => 931288, "shortname" => "test", "name" => "Aaron's Test Group" },
              { "ID" => 931286, "shortname" => "youth", "name" => "Youth Ministry" }
            ]
          }
        )
        allow(session).to receive(:get).with("network/getMetadata").and_return(
          { "everyoneGroupID" => 931283 }
        )
      end

      it "falls back to navigation groups and prepends Everyone", aggregate_failures: true do
        expect(dashboard.group_attributes).to eq(
          [
            { id: 931283, short_name: "everyone", name: "Everyone" },
            { id: 931288, short_name: "test", name: "Aaron's Test Group" },
            { id: 931286, short_name: "youth", name: "Youth Ministry" }
          ]
        )
      end
    end

    context "with a live session", :vcr do
      let(:session) do
        Flockbot::Session.new(
          subdomain: ENV["FLOCKNOTE_SUBDOMAIN"],
          email: ENV["FLOCKNOTE_USER_EMAIL"]
        ).tap do |s|
          s.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])
        end
      end

      let(:dashboard) { described_class.new(session:) }

      it "returns an array of group attributes", aggregate_failures: true do
        expect(dashboard.group_attributes).to be_an(Array)
        expect(dashboard.group_attributes.first).to include(
          id: an_instance_of(Integer),
          short_name: a_string_matching(/\w+/),
          name: a_string_matching(/\w+/)
        )
      end
    end
  end
end
