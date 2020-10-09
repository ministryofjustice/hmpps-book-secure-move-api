require 'active_support/concern'

module LocationValidations
  extend ActiveSupport::Concern

  included do |sti_klass|
    location_key = sti_klass::LOCATION_ATTRIBUTE_KEY

    sti_klass.define_method(location_key) do
      details[location_key]
    end

    sti_klass.define_method("#{location_key}=") do |location_id|
      details[location_key] = location_id
    end

    validates_each location_key do |_record, _attr, value|
      Location.find(value)
    end
  end
end
