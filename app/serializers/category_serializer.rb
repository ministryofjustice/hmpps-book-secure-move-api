# frozen_string_literal: true

class CategorySerializer
  include JSONAPI::Serializer

  set_type :categories

  attributes :key, :title, :move_supported
end
