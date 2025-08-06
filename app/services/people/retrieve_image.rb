# frozen_string_literal: true

module People
  class RetrieveImage
    def self.call(person, force_update: false)
      return true if person.image.attached? && !force_update
      return false unless person.latest_nomis_booking_id

      # Check if image exists before attempting to retrieve to avoid 404
      return false unless PrisonerSearchApiClient::Prisoner.facial_image_exists?(prison_number: person.prison_number)

      image_blob = NomisClient::Image.get(person.latest_nomis_booking_id)

      if image_blob
        person.attach_image(image_blob)
        true
      else
        false
      end
    end
  end
end
