# frozen_string_literal: true

module V2
  class ProfileSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :assessment_answers,
      :profile_identifiers,
      :latest_nomis_booking_id,
      :last_synced_with_nomis,
    )
  end
end
