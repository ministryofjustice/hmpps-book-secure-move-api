# frozen_string_literal: true

class RegionSerializer < ActiveModel::Serializer
  attributes :key, :name, :created_at, :updated_at

  has_many :locations

  SUPPORTED_RELATIONSHIPS = %w[locations].freeze
end
