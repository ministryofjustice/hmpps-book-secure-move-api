module FrameworkNomisMappings
  class Assessments
    attr_reader :booking_id, :nomis_sync_status

    def initialize(booking_id:, nomis_sync_status: FrameworkNomisMappings::NomisSyncStatus.new(resource_type: 'assessments'))
      @booking_id = booking_id
      @nomis_sync_status = nomis_sync_status
    end

    def call
      return [] if booking_id.blank?

      build_mappings.compact
    end

  private

    def imported_assessments
      @imported_assessments ||= NomisClient::Assessments.get(booking_id: booking_id).tap do
        nomis_sync_status.set_success
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, OAuth2::Error => e
      Rails.logger.warn "Importing framework assessments mappings error: #{e.message}"
      nomis_sync_status.set_failure(message: e.message)

      []
    end

    def build_mappings
      imported_assessments.map do |assessment|
        next unless valid_assessment?(assessment)

        FrameworkNomisMapping.new(
          raw_nomis_mapping: assessment,
          code_type: 'assessment',
          code: assessment[:assessment_code],
          code_description: assessment[:assessment_description],
          comments: assessment_comments(assessment),
          approval_date: assessment[:approval_date],
          next_review_date: assessment[:next_review_date],
        )
      end
    end

    def assessment_comments(assessment)
      [assessment[:classification], assessment[:assessment_comment]].compact_blank.join(' — ')
    end

    def valid_assessment?(assessment)
      next_review_date = assessment[:next_review_date].present? ? Date.parse(assessment[:next_review_date]) : nil
      next_review_date.nil? || next_review_date >= Time.zone.today
    end
  end
end
