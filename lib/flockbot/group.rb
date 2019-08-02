module Flockbot
  class Group
    def initialize(connection)
      @connection = connection
    end

    def search(group_id, term)
      url = "group/#{group_id}/search"
      params = { s: term, includeUnsubscribed: 0 }
      @connection.post url, params
    end
  end
end