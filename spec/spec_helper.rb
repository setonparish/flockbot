require "dotenv/load"
require "flockbot"
require "bundler/setup"
require "vcr"
require "pry"

Dotenv.load(".env.test", ".env.test.local", ".env")

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :faraday
  c.configure_rspec_metadata!

  #
  # Redact user email from VCR cassettes
  #
  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-EMAIL]") do
    ENV["FLOCKNOTE_USER_EMAIL"]
  end

  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-EMAIL]") do
    URI.encode_uri_component(ENV["FLOCKNOTE_USER_EMAIL"])
  end

  #
  # Redact user password from VCR cassettes
  #
  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-PASSWORD]") do
    ENV["FLOCKNOTE_USER_PASSWORD"] || URI.encode_uri_component(ENV["FLOCKNOTE_USER_PASSWORD"])
  end

  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-PASSWORD]") do
    URI.encode_uri_component(ENV["FLOCKNOTE_USER_PASSWORD"])
  end

  #
  # Redact one time code
  #
  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-USER-ONE-TIME-CODE]") do
    ENV["FLOCKNOTE_USER_ONE_TIME_CODE"]
  end

  #
  # Replace Flocknote cookie with fake data
  #
  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-COOKIE]") do |interaction|
    if interaction.response.headers["set-cookie"] || interaction.request.headers["Cookie"]
      flocknote_session = [
        interaction.response.headers["set-cookie"],
        interaction.request.headers["Cookie"]
      ].flatten.compact.find { |header| header.include?('Flocknote=') }

      if flocknote_session
        match = flocknote_session.match(/Flocknote=([^;]+);?/)
        match[1] if match
      end
    end
  end

  #
  # Replace Flocknote-Login-xxxxxx cookie with fake data
  #
  c.filter_sensitive_data("[REDACTED-FLOCKNOTE-LOGIN-COOKIE]") do |interaction|
    if interaction.response.headers["set-cookie"] || interaction.request.headers["Cookie"]
      flocknote_login_session = [
        interaction.response.headers["set-cookie"],
        interaction.request.headers["Cookie"]
      ].flatten.compact.find { |header| header.match(/Flocknote-Login/) }

      if flocknote_login_session
        match = flocknote_login_session.match(/Flocknote-Login-[1-9]+=([^;]+);?/)
        match[1] if match
      end
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
