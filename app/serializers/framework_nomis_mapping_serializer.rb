class FrameworkNomisMappingSerializer < ActiveModel::Serializer
  type 'framework_nomis_mappings'

  attributes :code, :code_type, :code_description, :comments, :start_date, :end_date, :creation_date, :expiry_date
end
