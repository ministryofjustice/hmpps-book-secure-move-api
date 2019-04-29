# frozen_string_literal: true

module Sessions
  class UserTokenFactory
    def create(auth_hash)
      UserToken.create!(
        access_token: access_token_from(auth_hash),
        refresh_token: refresh_token_from(auth_hash),
        expires_at: expires_at_from(auth_hash),
        user_name: user_name_from(auth_hash),
        user_id: user_id_from(auth_hash)
      )
    end

    def access_token_from(auth_hash)
      auth_hash['credentials']['token']
    end

    def refresh_token_from(auth_hash)
      auth_hash['credentials']['refresh_token']
    end

    def expires_at_from(auth_hash)
      Time.at(auth_hash['credentials']['expires_at']).utc
    end

    def user_name_from(auth_hash)
      auth_hash['extra']['raw_info']['name']
    end

    def user_id_from(auth_hash)
      auth_hash['extra']['raw_info']['username']
    end
  end
end
