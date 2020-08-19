class FrameworkFlagSerializer < ActiveModel::Serializer
  belongs_to :framework_question, key: :question

  attributes :flag_type, :title, :question_value

  SUPPORTED_RELATIONSHIPS = %w[
    question
  ].freeze
end
