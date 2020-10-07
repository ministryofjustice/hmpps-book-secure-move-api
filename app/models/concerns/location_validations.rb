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

    validates location_key, presence: true
    validates_each location_key do |record, attr, value|
      Location.find(value)
    rescue ActiveRecord::RecordNotFound
      record.errors.add(attr, "The location relationship you passed has an id that does not exist in our system. Please use an existing #{location_key.to_s.sub('_id', '')}")
    end
  end
end
