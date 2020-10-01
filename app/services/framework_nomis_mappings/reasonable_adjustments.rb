module FrameworkNomisMappings
  class ReasonableAdjustments
    attr_reader :booking_id, :nomis_codes

    def initialize(booking_id:, nomis_codes:)
      @booking_id = booking_id
      @nomis_codes = nomis_codes
    end

    def call
      return [] unless booking_id && nomis_codes.any?

      build_mappings.compact
    end

  private

    def imported_reasonable_adjustments
      @imported_reasonable_adjustments ||= NomisClient::ReasonableAdjustments.get(booking_id: booking_id, reasonable_adjustment_types: nomis_codes.pluck(:code).compact.join(','))
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, OAuth2::Error => e
      Rails.logger.warn "Importing Framework reasonable adjustment mappings Error: #{e.message}"

      []
    end

    def build_mappings
      imported_reasonable_adjustments.map do |reasonable_adjustment|
        next unless valid_reasonable_adjustment?(reasonable_adjustment[:end_date])

        FrameworkNomisMapping.new(
          raw_nomis_mapping: reasonable_adjustment,
          code_type: 'reasonable_adjustment',
          code: reasonable_adjustment[:treatment_code],
          code_description: reasonable_adjustment[:treatment_description],
          comments: reasonable_adjustment[:comment_text],
          start_date: reasonable_adjustment[:start_date],
          end_date: reasonable_adjustment[:end_date],
        )
      end
    end

    def valid_reasonable_adjustment?(date)
      end_date = Date.parse(date) if date.present?

      end_date.nil? || end_date >= Time.zone.today
    end
  end
end
