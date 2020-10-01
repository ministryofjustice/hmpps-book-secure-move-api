module FrameworkNomisMappings
  class PersonalCareNeeds
    PERSONAL_CARE_NEED_CODES = 'SC,MATSTAT,PHY,PSYCH,DISAB'.freeze
    attr_reader :prison_number

    def initialize(prison_number:)
      @prison_number = prison_number
    end

    def call
      return [] unless prison_number

      build_mappings.compact
    end

  private

    def imported_personal_care_needs
      @imported_personal_care_needs ||= NomisClient::PersonalCareNeeds.get(nomis_offender_numbers: [prison_number], personal_care_types: PERSONAL_CARE_NEED_CODES)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, OAuth2::Error => e
      Rails.logger.warn "Importing Framework personal care needs mappings Error: #{e.message}"

      []
    end

    def build_mappings
      imported_personal_care_needs.map do |personal_care_need|
        next unless valid_personal_care_need?(personal_care_need[:end_date], personal_care_need[:problem_status])

        FrameworkNomisMapping.new(
          raw_nomis_mapping: personal_care_need,
          code_type: 'personal_care_need',
          code: personal_care_need[:problem_code],
          code_description: personal_care_need[:problem_description],
          start_date: personal_care_need[:start_date],
          end_date: personal_care_need[:end_date],
        )
      end
    end

    def valid_personal_care_need?(date, status)
      end_date = Date.parse(date) if date.present?

      status == 'ON' && (end_date.nil? || end_date >= Time.zone.today)
    end
  end
end
