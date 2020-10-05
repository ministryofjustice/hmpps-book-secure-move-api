# frozen_string_literal: true

class NomisApiErrorSerializer
  include JSONAPI::Serializer

  set_type :nomis_api_errors

  attributes :code, :status, :title, :details
end
