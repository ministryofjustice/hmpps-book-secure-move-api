class FrameworkQuestionSerializer < ActiveModel::Serializer
  belongs_to :framework

  attributes :key, :section, :question_type, :options, :response_type
  has_many :dependents, key: :descendants

  def response_type
    case object.question_type
    when 'radio'
      object.followup_comment ? 'object' : 'string'
    when 'checkbox'
      object.followup_comment ? 'collection' : 'array'
    when 'add_multiple_items'
      'collection::add_multiple_items'
    else
      'string'
    end
  end

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    descendants
  ].freeze
end
