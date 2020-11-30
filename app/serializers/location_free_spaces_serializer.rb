# frozen_string_literal: true

class LocationFreeSpacesSerializer
  include JSONAPI::Serializer

  set_type :locations

  attributes :title

  belongs_to :category

  meta do |object, params|
    {
      populations: params.dig(:spaces, object.id),
    }
  end

  SUPPORTED_RELATIONSHIPS = %w[category].freeze
end
