# frozen_string_literal: true

module NomisClient
  class Contacts < NomisClient::Base
    class << self
      def get(booking_id:)
        return [] if booking_id.blank?

        response = get_response(booking_id: booking_id)

        next_of_kin = response.fetch('nextOfKin', []).map { |contact| attributes_for(contact, next_of_kin: true) }
        other_contacts = response.fetch('otherContacts', []).map { |contact| attributes_for(contact, next_of_kin: false) }

        next_of_kin.concat(other_contacts)
      end

      def get_response(booking_id:)
        NomisClient::Base.get("/bookings/#{booking_id}/contacts").parsed
      end

      def attributes_for(contact, next_of_kin:)
        contact.transform_keys { |key| key.underscore.to_sym }.merge(next_of_kin: next_of_kin)
      end
    end
  end
end
