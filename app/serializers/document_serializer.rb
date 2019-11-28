# frozen_string_literal: true

class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :filename, :content_type

  def filename
    object.file.filename
  end

  def content_type
    object.file.content_type
  end
end
