# frozen_string_literal: true

module ManageUsersApiClient
  class UserEmail < ManageUsersApiClient::Base
    class << self
      def get(username)
        return nil if username.blank?
        return username if username =~ URI::MailTo::EMAIL_REGEXP

        JSON.parse(fetch_response(username).body)['email']
      rescue OAuth2::Error
        nil
      end

      def fetch_response(username)
        ManageUsersApiClient::Base.get("/users/#{username}/email")
      end
    end
  end
end
