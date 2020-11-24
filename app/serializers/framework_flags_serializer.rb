# frozen_string_literal: true

class FrameworkFlagsSerializer
  include JSONAPI::Serializer

  set_type :framework_flags

  attributes :flag_type, :title, :question_value
end
