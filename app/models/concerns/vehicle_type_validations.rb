require 'active_support/concern'

module VehicleTypeValidations
  extend ActiveSupport::Concern

  included do
    attribute :vehicle_type, :string
    enum :vehicle_type, {
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
