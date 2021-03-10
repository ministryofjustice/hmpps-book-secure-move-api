# frozen_string_literal: true

class LocationSerializer < LocationsSerializer
  set_type :locations

  has_many :suppliers

  SUPPORTED_RELATIONSHIPS = %w[suppliers].freeze
end
