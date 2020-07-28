class FrameworkQuestionSerializer < ActiveModel::Serializer
  belongs_to :framework

  attributes :key, :section, :question_type, :options

  SUPPORTED_RELATIONSHIPS = %w[
    framework
  ].freeze
end
