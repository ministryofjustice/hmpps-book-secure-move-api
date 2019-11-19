# frozen_string_literal: true

class DocumentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :description, :document_type, :file

  has_one :move, serializer: MoveSerializer

  def file
    rails_blob_path(object.file)
  end
end
