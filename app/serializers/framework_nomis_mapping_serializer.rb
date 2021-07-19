# frozen_string_literal: true

class FrameworkNomisMappingSerializer
  include JSONAPI::Serializer

  set_type :framework_nomis_mappings

  attributes :code, :code_type, :code_description, :comments, :start_date, :end_date, :creation_date, :expiry_date, :approval_date, :next_review_date
end
