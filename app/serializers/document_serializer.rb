# frozen_string_literal: true

class DocumentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::NumberHelper

  attributes :id, :url, :filename, :filesize, :content_type

  def url
    object.file.service_url
  end

  def filename
    object.file.filename
  end

  def filesize
    object.file.byte_size
  end

  def content_type
    object.file.content_type
  end
end
