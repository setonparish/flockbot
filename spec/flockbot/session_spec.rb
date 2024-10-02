require "spec_helper"

RSpec.describe Flockbot::Session, :vcr do
  let(:session) do
    Flockbot::Session.new(
      subdomain: ENV["FLOCKNOTE_SUBDOMAIN"],
      email: ENV["FLOCKNOTE_USER_EMAIL"]
    )
  end

  describe "#login!" do
    context "using a password" do
      context "when the password is valid" do
        it "successfully logs in", aggregate_failures: true do
          expect(session.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])).to eq(true)
          expect(session.session_token).to_not be_nil
          expect(session.logged_in?).to eq(true)
        end
      end

      context "when the password is invalid" do
        it "successfully logs in", aggregate_failures: true do
          expect {
            session.login!(password: "invalid-password")
          }.to raise_error(Flockbot::SessionLoginError, "Unable to login")
          expect(session.session_token).to_not be_nil
          expect(session.logged_in?).to eq(false)
        end
      end
    end

    context "using a one time code" do
      context "when the code is valid" do
        it "successfully logs in", aggregate_failures: true do
          if ENV["FLOCKNOTE_USER_ONE_TIME_CODE"].nil? || ENV["FLOCKNOTE_USER_ONE_TIME_CODE"] == ""
            session.send_one_time_code
            raise "You generated a new one time code.  Now set the `FLOCKNOTE_USER_ONE_TIME_CODE` environment variable to the new code that was emailed to you."
          end

          expect(session.login!(code: ENV["FLOCKNOTE_USER_ONE_TIME_CODE"])).to eq(true)
          expect(session.session_token).to_not be_nil
          expect(session.logged_in?).to eq(true)
        end
      end

      context "when the code is invalid" do
        it "successfully logs in", aggregate_failures: true do
          expect {
            session.login!(code: "invalid-code")
          }.to raise_error(Flockbot::SessionLoginError, "Unable to login")
          expect(session.session_token).to_not be_nil
          expect(session.logged_in?).to eq(false)
        end
      end
    end

    context "using a previously saved session token" do
      let(:session_token) do
        session.login!(password: ENV["FLOCKNOTE_USER_PASSWORD"])
        session.session_token
      end

      context "when the token is valid" do
        it "successfully logs in", aggregate_failures: true do
          new_session = Flockbot::Session.new(
            subdomain: ENV["FLOCKNOTE_SUBDOMAIN"],
            email: ENV["FLOCKNOTE_USER_EMAIL"]
          )

          expect(new_session.login!(token: session_token)).to eq(true)
          expect(new_session.session_token).to eq(session_token)
          expect(new_session.logged_in?).to eq(true)
        end
      end

      context "when the token is invalid" do
        it "successfully logs in", aggregate_failures: true do
          expect {
            session.login!(token: "invalid-token")
          }.to raise_error(Flockbot::SessionLoginError, "Unable to login")
          expect(session.session_token).to_not be_nil
          expect(session.logged_in?).to eq(false)
        end
      end
    end
  end
end
