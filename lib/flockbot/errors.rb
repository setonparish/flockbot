module Flockbot
  class FlockbotError < StandardError; end;
  class AuthenticationError < FlockbotError; end;
end