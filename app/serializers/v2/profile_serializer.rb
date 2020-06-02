# frozen_string_literal: true

module V2
  class ProfileSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :assessment_answers,
      :latest_nomis_booking_id,
    )
  end
end
