require "spec_helper"

RSpec.describe Flockbot::Connection, :vcr do
  let(:connection) { Flockbot::Connection.new(subdomain: ENV["FLOCKNOTE_SUBDOMAIN"]) }

  describe "#get" do
    it "returns an html body" do
      response = connection.get("/")
      expect(response).to include("Sign up here to get updates")
    end
  end

  describe "#post" do
    it "posts a json payload and gets a json response" do
      response = connection.post("login/twoFactorAuth", {})
      expect(response["success"]).to eq(true)
    end
  end

  describe "#session_token" do
    it "extracts the flocknote session token" do
      connection.get("/")
      expect(connection.session_token).to eq("[REDACTED-FLOCKNOTE-COOKIE]")
    end
  end

  describe "#set_session_token" do
    it "sets a flocknote session token" do
      connection.set_session_token("previous-flocknote-session-token")
      expect(connection.session_token).to eq("previous-flocknote-session-token")
    end
  end

  describe "#inspect" do
    it "does not contain verbose information" do
      connection.get("/")
      expect(connection.inspect).to_not include(/faraday/i)
    end
  end
end
