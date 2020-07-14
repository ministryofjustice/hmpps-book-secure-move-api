class FrameworkQuestionSerializer < ActiveModel::Serializer
  belongs_to :framework

  attributes :key, :question_type, :options

  SUPPORTED_RELATIONSHIPS = %w[
    framework
  ].freeze
end
