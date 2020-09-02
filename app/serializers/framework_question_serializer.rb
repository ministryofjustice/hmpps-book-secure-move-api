class FrameworkQuestionSerializer < ActiveModel::Serializer
  belongs_to :framework

  attributes :key, :section, :question_type, :options, :response_type
  has_many :dependents, key: :descendants
  has_one :last_response

  def last_response
    object.framework_responses.where(person_escort_record: instance_options[:per]).presence&.first
  end

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    descendants
    last_response
  ].freeze
end
