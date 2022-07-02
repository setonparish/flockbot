require "flockbot"
require "bundler/setup"
require "vcr"
require "pry"

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

  c.filter_sensitive_data("me@example.com") do |interaction|
    expression = %r("email":"(.+?)")
    match = interaction.request.body.match(expression)[1]
    URI.decode(match)
  end

  c.filter_sensitive_data("<PASSWORD>") do |interaction|
    expression = %r("password":"(.+?)")
    interaction.request.body.match(expression)[1]
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
