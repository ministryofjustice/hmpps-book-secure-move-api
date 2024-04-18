# frozen_string_literal: true

require 'base64'

# :nocov:
module HmppsApi
  module Oauth
    module ClientHelper
      def user_login_authorisation
        "Basic #{Base64.urlsafe_encode64(
          "#{ENV['NOMIS_CLIENT_ID']}:#{ENV['NOMIS_CLIENT_SECRET']}",
        )}"
      end
    end
  end
end
# :nocov:
