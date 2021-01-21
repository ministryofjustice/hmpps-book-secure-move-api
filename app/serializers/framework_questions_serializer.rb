# frozen_string_literal: true

class FrameworkQuestionsSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :framework_questions

  attributes :key, :section, :question_type, :options, :response_type

  has_many_if_included :descendants, serializer: FrameworkQuestionsSerializer, &:dependents
  has_many_if_included :flags, serializer: FrameworkFlagsSerializer, &:framework_flags
end
