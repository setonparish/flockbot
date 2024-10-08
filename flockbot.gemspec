lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flockbot/version"

Gem::Specification.new do |spec|
  spec.name          = "flockbot"
  spec.version       = Flockbot::VERSION
  spec.authors       = ["Seton Parish"]
  spec.email         = ["hello@setonparish.com"]

  spec.summary       = "Wrapping the flocknote.com site as an API"
  spec.homepage      = "https://github.com/setonparish/flockbot"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dotenv"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday-cookie_jar"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
end
