class FlagSerializer < ActiveModel::Serializer
  type :framework_flags
  belongs_to :framework_question, key: :question

  attributes :flag_type, :name, :question_value

  SUPPORTED_RELATIONSHIPS = %w[
    question
  ].freeze
end
