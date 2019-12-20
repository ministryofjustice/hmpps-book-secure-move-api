# frozen_string_literal: true

class DocumentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::NumberHelper

  attributes :id, :url, :filename, :filesize, :content_type

  def url
    url_for(object.file)
  end

  def filename
    object.file.filename
  end

  def filesize
    number_to_human_size(object.file.byte_size, precision: 2)
  end

  def content_type
    object.file.content_type
  end
end
