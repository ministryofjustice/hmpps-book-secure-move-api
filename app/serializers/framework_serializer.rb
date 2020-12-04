# frozen_string_literal: true

class FrameworkSerializer
  include JSONAPI::Serializer

  set_type :frameworks

  has_many :questions, &:framework_questions

  attributes :name, :version

  SUPPORTED_RELATIONSHIPS = %w[
    questions
  ].freeze
end
