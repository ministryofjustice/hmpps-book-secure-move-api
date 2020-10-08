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
      'c4': 'c4',
      'pro_cab': 'pro_cab',
      'mpv': 'mpv',
      '2_cell': '2_cell',
      '3_cell': '3_cell',
      '6_cell': '6_cell',
      '12_cell': '12_cell',
    }

    validates :vehicle_type, inclusion: { in: vehicle_types }
  end
end
