# frozen_string_literal: true

module Sessions
  class UserTokenFactory
    attr_reader :auth_hash

    def initialize(auth_hash)
      @auth_hash = auth_hash
    end

    def find_or_create
      return existing_user_token if existing_user_token.present?

      UserToken.create!(
        access_token: access_token,
        refresh_token: refresh_token,
        expires_at: expires_at,
        user_name: user_name,
        user_id: user_id
      )
    end

    def existing_user_token
      @existing_user_token ||= UserToken.where(access_token: access_token).first
    end

    def access_token
      auth_hash['credentials']['token']
    end

    def refresh_token
      auth_hash['credentials']['refresh_token']
    end

    def expires_at
      Time.at(auth_hash['credentials']['expires_at']).utc
    end

    def user_name
      auth_hash['extra']['raw_info']['name']
    end

    def user_id
      auth_hash['extra']['raw_info']['username']
    end
  end
end
