require 'active_support/concern'

module VehicleTypeValidations
  extend ActiveSupport::Concern

  def vehicle_type=(vehicle_type)
    details['vehicle_type'] = vehicle_type
  end

  def vehicle_type
    details['vehicle_type']
  end

  included do
    enum vehicle_type: {
      cellular: 'cellular',
      mpv: 'mpv',
      other: 'other',
    }

    validates :vehicle_type, inclusion: { in: vehicle_types }
  end
end
