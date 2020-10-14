require 'active_support/concern'

module VehicleRegValidations
  extend ActiveSupport::Concern

  included do
    validates :vehicle_reg, presence: true
  end
end
