require 'active_support/concern'

module Geocodeable
  extend ActiveSupport::Concern

  included do
    after_validation :set_coordinates
    geocoded_by :postcode
  end

  def coordinates
    [latitude, longitude]
  end

  def set_coordinates
    return unless kept?
    return unless postcode
    return unless postcode_changed? || coordinates.compact.empty?

    geocode
  end
end
