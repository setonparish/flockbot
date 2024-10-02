require "faraday"

module Flockbot
  class FlockbotError < StandardError; end;
  class SessionLoginError < FlockbotError; end
  class TransactionError < FlockbotError; end

  #
  # If the request to Flocknotes is an http status 200 response, but the action
  # being performed is not successful, Flocknote will return a { success: false }
  # status with an error, so raise this.
  #
  class CustomErrors < Faraday::Middleware
    def on_complete(env)
      case env[:status]
      when 200
        return unless env.response_headers["content-type"] == "application/json"
        json = env.body.is_a?(String) ? JSON.parse(env.body) : env.body

        return unless json.has_key?("success")

        if !json["success"]
          raise Flockbot::TransactionError.new(json["message"])
        end
      end
    end
  end
end
