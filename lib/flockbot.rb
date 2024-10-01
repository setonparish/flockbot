require "flockbot/client"
require "flockbot/connection"
require "flockbot/errors"
require "flockbot/version"

module Flockbot
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :subdomain, :email, :password

    def initialize
      @subdomain ||= ENV["FLOCKBOT_SUBDOMAIN"]
      @email ||= ENV["FLOCKBOT_EMAIL"]
      @password ||= ENV["FLOCKBOT_PASSWORD"]
    end
  end
end

Flockbot.configuration = Flockbot::Configuration.new