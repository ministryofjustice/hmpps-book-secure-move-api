class FrameworkNomisMappingSerializer < ActiveModel::Serializer
  type 'framework_nomis_mappings'
  has_many :framework_responses, key: :responses

  attributes :code, :code_type, :code_description, :comments, :start_date, :end_date, :creation_date, :expiry_date

  SUPPORTED_RELATIONSHIPS = %w[
    responses
  ].freeze
end
