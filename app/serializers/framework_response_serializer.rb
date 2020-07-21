class FrameworkResponseSerializer < ActiveModel::Serializer
  type 'framework_responses'
  belongs_to :person_escort_record
  belongs_to :framework_question, key: :question
  has_many :flags

  attributes :value, :value_type, :responded

  def value_type
    case object.type
    when 'FrameworkResponse::String'
      'string'
    when 'FrameworkResponse::Array'
      'array'
    when 'FrameworkResponse::Object'
      'object'
    when 'FrameworkResponse::Collection'
      'collection'
    end
  end

  SUPPORTED_RELATIONSHIPS = %w[
    person_escort_record
    question
    flags
  ].freeze
end
