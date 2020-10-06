# frozen_string_literal: true

class DocumentSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::NumberHelper

  set_type :documents

  attribute :url do |object|
    object.file.service_url
  end

  attribute :filename do |object|
    object.file.filename
  end

  attribute :filesize do |object|
    object.file.byte_size
  end

  attribute :content_type do |object|
    object.file.content_type
  end
end
