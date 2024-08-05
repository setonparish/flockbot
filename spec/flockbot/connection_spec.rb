require "spec_helper"

RSpec.describe "Flockbot::Connection", :vcr do
  it "raises error with invalid flocknote credentials" do
    service = Flockbot::Connection.new(subdomain: "subdomain", email: "me@example.com", password: "incorrect")
    expect { service.connect! }.to raise_error { Flockbot::TransactionError }
  end

  it "connects successfully with valid flocknote credentials" do
    service = Flockbot::Connection.new(subdomain: "subdomain", email: "me@example.com", password: "mypassword")
    service.connect!
    expect(service.connected).to eq(true)
  end
end
