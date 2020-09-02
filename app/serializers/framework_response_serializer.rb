class FrameworkResponseSerializer < ActiveModel::Serializer
  type 'framework_responses'
  belongs_to :person_escort_record
  belongs_to :framework_question, key: :question
  has_many :framework_flags, key: :flags

  attributes :value, :value_type, :responded

  def value_type
    object.framework_question.response_type
  end

  SUPPORTED_RELATIONSHIPS = %w[
    person_escort_record
    question.descendants
    question.last_response
    flags
  ].freeze
end
