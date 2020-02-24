# frozen_string_literal: true

class ApplicationController < ActionController::API
  # This is needed to prevent HighVoltage crashing when eager_load is set true
  # (annoyingly only in prod-like environments) as it's confused by our ApplicationController
  # not inheriting from ActiveController::Base. We override HighVoltage's PageController class
  # but sadly it still loads and breaks badly without this little 'fix'
  #:nocov:
  def self.layout(_)
    'application'
  end
end
