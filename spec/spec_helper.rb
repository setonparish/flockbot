require "dotenv/load"
require "flockbot"
require "bundler/setup"
require "vcr"
require "pry"

Dotenv.load(".env.test", ".env.test.local", ".env")
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :faraday
  c.configure_rspec_metadata!

  c.filter_sensitive_data("subdomain") do |interaction|
    expression = /https:\/\/(\w+)\W/
    if match = interaction.request.uri.match(expression)
      match[1]
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
