# This has to be overridden as our ApplicationController
# doesn't inherit from ActionController::Base

# rubocop:disable Rails/ApplicationController
class PagesController < ActionController::Base
  include HighVoltage::StaticPage
end
# rubocop:enable Rails/ApplicationController
