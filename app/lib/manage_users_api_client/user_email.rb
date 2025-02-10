# frozen_string_literal: true

module ManageUsersApiClient
  class UserEmail < ManageUsersApiClient::Base
    class << self
      def get(username)
        JSON.parse(fetch_response(username).body)['email']
      end

      def fetch_response(username)
        ManageUsersApiClient::Base.get("/users/#{username}/email")
      end
    end
  end
end
