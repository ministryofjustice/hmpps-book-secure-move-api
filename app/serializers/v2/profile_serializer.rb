# frozen_string_literal: true

module V2
  class ProfileSerializer < ActiveModel::Serializer
    attributes(
      :assessment_answers,
    )
  end
end
