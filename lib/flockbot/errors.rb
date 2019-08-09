require "faraday"

module Flockbot
  class FlockbotError < StandardError; end;
  class TransactionError < FlockbotError; end

  #
  # If the request to Flocknotes is an http status 200 response, but the action
  # being performed is not successful, Flocknote will return a { success: false }
  # status with an error, so raise this.
  #
  class CustomErrors < Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 200
        return unless env.response_headers["content-type"] == "application/json"
        return unless env.body.has_key?("success")

        if !env.body["success"]
          raise Flockbot::TransactionError.new(env.body["message"])
        end
      end
    end
  end
end
