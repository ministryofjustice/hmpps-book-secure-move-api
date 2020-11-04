# frozen_string_literal: true

class CategorySerializer
  include JSONAPI::Serializer

  set_type :categories
  set_id :key

  attributes :title, :move_supported
end
