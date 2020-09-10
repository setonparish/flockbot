require "spec_helper"

RSpec.describe "Flockbot::Models::Group", :vcr do
  let(:service) { Flockbot::Models::Group.new(attrs, connection) }
  let(:connection) { double(:connection, get: response, post: response) }
  let(:response) { {} }

  describe "#initialize" do
    let(:attrs) do
      {
        id: "1",
        name: "Everyone",
        short_name: "everyone",
      }
    end

    it "sets correct attributes" do
      aggregate_failures do
        expect(service.id).to eq("1")
        expect(service.name).to eq("Everyone")
        expect(service.short_name).to eq("everyone")
      end
    end
  end

  describe "#everyone?" do
    context "with a short name of 'everyone'" do
      let(:attrs) do
        { short_name: "everyone" }
      end

      it "is true" do
        expect(service.everyone?).to eq(true)
      end
    end

    context "without a short name of 'everyone'" do
      let(:attrs) do
        { short_name: "not everyone" }
      end

      it "is false" do
        expect(service.everyone?).to eq(false)
      end
    end
  end

  describe "#subscriber_count" do
    let(:attrs) do
      { "id" => 999 }
    end

    let(:response) do
      { "subscriberCount" => "333" }
    end

    it "extracts the subscriber count as an integer" do
      expect(service.subscriber_count).to eq(333)
    end
  end

  describe "#add_user" do
    let(:attrs) do
      { id: "999" }
    end

    let(:response) do
      { "success" => true }
    end

    it "adds a new user to a group" do
      params = {
        first_name: "First",
        last_name: "Last",
        email: "me@example.com",
        mobile_phone: "555-555-5555"
      }

      expect(connection).to receive(:post).with(
        "/group/999/addToGroupByAdmin",
        {
          fname: "First",
          lname: "Last",
          email: "me@example.com",
          mobile_phone: "555-555-5555"
        }
      )
      expect(service.add_user(params)).to eq(true)
    end
  end
end
