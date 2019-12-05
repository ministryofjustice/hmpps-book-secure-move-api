# frozen_string_literal: true

class DocumentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers 
  
  attributes :id, :url, :filename, :content_type

  def url
    rails_blob_path(object.file)
  end

  def filename
    object.file.filename
  end

  def content_type
    object.file.content_type
  end
end
