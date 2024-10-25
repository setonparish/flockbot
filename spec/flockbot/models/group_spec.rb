require "spec_helper"

RSpec.describe Flockbot::Models::Group, :vcr do
  let(:flocknote_group_id) do
    # an actual existing group id in flocknote
    "931288"
  end

  let(:session) do
    Flockbot::Session.new(
      subdomain: ENV["FLOCKNOTE_SUBDOMAIN"],
      email: ENV["FLOCKNOTE_USER_EMAIL"]
    )
  end

  describe "#initialize" do
    let(:group) do
      Flockbot::Models::Group.new(
        id: flocknote_group_id,
        name: "My Group\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n\t\t\t\t\t",
        short_name: "MyGroup",
        session:
      )
    end

    it "sets correct attributes", aggregate_failures: true do
      expect(group.id).to eq(flocknote_group_id)
      expect(group.name).to eq("My Group")
      expect(group.short_name).to eq("MyGroup")
    end
  end

  describe "#inspect" do
    let(:group) do
      Flockbot::Models::Group.new(
        id: flocknote_group_id,
        name: "My Group",
        short_name: "my group",
        session:
      )
    end

    it "does not contain session information", aggregate_failures: true do
      inspected = group.send(:inspect)
      expect(inspected).to include(/short_name/)
      expect(inspected).to_not include(/session/)
    end
  end

  describe "#everyone?" do
    let(:group) do
      Flockbot::Models::Group.new(
        id: flocknote_group_id,
        name: "My Group",
        short_name: short_name,
        session:
      )
    end

    context "with a short name of 'everyone'" do
      let(:short_name) { "everyone" }

      it "is true" do
        expect(group.everyone?).to eq(true)
      end
    end

    context "without a short name of 'everyone'" do
      let(:short_name) { "not everyone" }

      it "is false" do
        expect(group.everyone?).to eq(false)
      end
    end
  end

  describe "#subscriber_count" do
    before do
      session.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])
    end

    let(:group) do
      Flockbot::Models::Group.new(
        id: flocknote_group_id,
        name: "Test Group",
        short_name: "test group",
        session:
      )
    end

    it "returns subscriber count" do
      expect(group.subscriber_count).to eq(2)
    end
  end

  describe "#add_user" do
    before do
      session.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])
    end

    let(:group) do
      Flockbot::Models::Group.new(
        id: flocknote_group_id,
        name: "Test Group",
        short_name: "test group",
        session:
      )
    end

    context "with valid user options" do
      it "adds a new user to a group" do
        expect(
          group.add_user(
            first_name: "Another",
            last_name: "Test User",
            email: "test@example.com",
            mobile_phone: nil
          )
        ).to eq(true)
      end
    end

    context "with invalid user options" do
      it "raises a transaction error" do
        expect {
          group.add_user(
            first_name: "Another",
            last_name: "Test User",
            email: "not-a-vaild-email",
            mobile_phone: nil
          )
        }.to raise_error(Flockbot::TransactionError, /something wrong with that email address/)
      end
    end
  end
end
