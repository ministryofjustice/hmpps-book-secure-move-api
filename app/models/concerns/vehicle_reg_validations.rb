require 'active_support/concern'

module VehicleRegValidations
  extend ActiveSupport::Concern

  def vehicle_reg=(vehicle_reg)
    details['vehicle_reg'] = vehicle_reg
  end

  def vehicle_reg
    details['vehicle_reg']
  end

  included do
    validates :vehicle_reg, presence: true
  end
end
