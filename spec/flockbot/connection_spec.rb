require "spec_helper"

RSpec.describe Flockbot::Connection, :vcr do
  context "with invalid flocknote credentials" do
    it "raises an error" do
      service = Flockbot::Connection.new(subdomain: "subdomain", email: "me@example.com", password: "incorrect")
      expect { service.connect! }.to raise_error { Flockbot::TransactionError }
    end
  end

  context "with valid flocknote credentials" do
    it "connects successfully" do
      service = Flockbot::Connection.new(subdomain: "subdomain", email: "me@example.com", password: "mypassword")
      service.connect!
      expect(service.connected).to eq(true)
    end
  end
end
