class NomisApiErrorSerializer < ActiveModel::Serializer::ErrorSerializer
  attributes :code, :status, :title, :details
end
