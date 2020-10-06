# frozen_string_literal: true

class ImageSerializer
  include JSONAPI::Serializer

  set_type :images

  attributes :url
end
