# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action do
    # This is to access S3 URLs with #service_url, which returns a url that expires in 5 Minutes
    # In contrast, url_for returns permanent URL, which for privacy/security reasons, we do not want.
    ActiveStorage::Current.host = request.base_url
  end
end
