module Flockbot
  class User
    def initialize(connection)
      @connection = connection
    end

    def super_search(term)
      params = {
        searchTerm: term,
        networkID: @connection.network_id,
        "filters[]": ["user"],
      }
      @connection.post "supersearch/query", params
    end

    def search(term)
      params = {
        s: term
      }
      response = @connection.post "/group/#{@connection.everyone_group_id}/search", params
      response["results"]
    end
  end
end