# frozen_string_literal: true

class ProfileSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :assessment_answers,
    :profile_identifiers,
    :aliases,
    :nationality_id,
    :latest_nomis_booking_id,
    :last_synced_with_nomis,
  )
end
