module FrameworkNomisMappings
  class Contacts
    attr_reader :booking_id, :nomis_sync_status

    def initialize(booking_id:, nomis_sync_status: FrameworkNomisMappings::NomisSyncStatus.new(resource_type: 'contacts'))
      @booking_id = booking_id
      @nomis_sync_status = nomis_sync_status
    end

    def call
      return [] if booking_id.blank?

      build_mappings.compact
    end

  private

    def imported_contacts
      @imported_contacts ||= NomisClient::Contacts.get(booking_id: booking_id).tap do
        nomis_sync_status.set_success
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, OAuth2::Error => e
      Rails.logger.warn "Importing framework contacts mappings error: #{e.message}"
      nomis_sync_status.set_failure(message: e.message)

      []
    end

    def build_mappings
      imported_contacts.map do |contact|
        next unless valid_contact?(contact)

        FrameworkNomisMapping.new(
          raw_nomis_mapping: contact,
          code_type: 'contact',
          code: contact_code(contact),
          code_description: contact_code_description(contact),
          comments: contact_comments(contact),
          creation_date: contact[:create_date_time],
          expiry_date: contact[:expiry_date],
        )
      end
    end

    def contact_code(contact)
      contact[:next_of_kin] ? 'NEXTOFKIN' : 'OTHER'
    end

    def contact_code_description(contact)
      contact[:next_of_kin] ? 'Next of Kin' : 'Other'
    end

    COMMENT_FIELDS = [
      %i[first_name middle_name last_name],
      %i[relationship_description],
      %i[comment_text],
    ].freeze

    def contact_comments(contact)
      COMMENT_FIELDS.map { |fields| fields.map { |f| contact[f] }.compact_blank.join(' ') }.compact_blank.join(' — ')
    end

    def valid_contact?(contact)
      contact[:active_flag]
    end
  end
end
