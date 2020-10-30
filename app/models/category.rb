# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :locations
  has_many :profiles

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :move_supported, presence: true

end

#
# TYPE = 'Category'.freeze
#
# attr_reader :id, :title, :move_supported
#
# def build_from_nomis(booking_details)
#   @id = booking_details[:category_code]
#   @title = booking_details[:category]
#   @move_supported = Move::UNSUPPORTED_PRISONER_CATEGORIES.exclude?(id)
#
#   self
# end
