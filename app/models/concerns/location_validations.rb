require 'active_support/concern'

module LocationValidations
  extend ActiveSupport::Concern

  included do |sti_klass|
    location_key = sti_klass::LOCATION_ATTRIBUTE_KEY

    validates_each location_key do |_record, _attr, value|
      Location.find(value)
    end
  end
end
