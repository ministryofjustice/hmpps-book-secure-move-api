# frozen_string_literal: true

class GenderSerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :description, :visible, :nomis_code
end
