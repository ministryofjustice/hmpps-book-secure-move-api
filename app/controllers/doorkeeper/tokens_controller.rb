module Doorkeeper
  class TokensController < Doorkeeper::ApplicationMetalController
    def create
      if authentication_enabled?
        headers.merge!(authorize_response.headers)
        render json: authorize_response.body, status: authorize_response.status
      else
        render json: { access_token: 'spoofed-token'  }
      end
    rescue Errors::DoorkeeperError => e
      handle_token_exception(e)
    end
  end
end
