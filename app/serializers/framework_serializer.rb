class FrameworkSerializer < ActiveModel::Serializer
  has_many :framework_questions, key: :questions

  attributes :name, :version

  SUPPORTED_RELATIONSHIPS = %w[
    questions
  ].freeze
end
