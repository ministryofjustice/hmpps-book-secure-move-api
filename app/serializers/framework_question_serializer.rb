class FrameworkQuestionSerializer < ActiveModel::Serializer
  belongs_to :framework

  attributes :key, :section, :question_type, :options, :response_type
  has_many :dependents, key: :descendants

  SUPPORTED_RELATIONSHIPS = %w[
    framework
    descendants
  ].freeze
end
