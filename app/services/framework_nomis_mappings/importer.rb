# frozen_string_literal: true

module FrameworkNomisMappings
  class Importer
    PERSONAL_CARE_NEED_CODES = "SC,MATSTAT,PHY,PSYCH,DISAB"

    attr_reader :framework_nomis_codes, :person, :mappings, :framework_responses
    def initialize(framework_nomis_codes:, person:, framework_responses:)
      @framework_nomis_codes = framework_nomis_codes
      @person = person
      @framework_responses = framework_responses
      @mappings = []
    end

    def call
      return unless framework_nomis_codes.present?

      mappings = import_personal_care_needs + import_alerts + import_reasonable_adjustments
      import = FrameworkNomisMapping.import(mappings.compact, validate: false, recursive: true, all_or_none: true)
      mappings = FrameworkNomisMapping.where(id: import.ids)
      framework_responses.each do |response|
        codes = response.framework_question.framework_nomis_codes.pluck(:code)
        response.framework_nomis_mappings = mappings.where(code: codes.compact)
          # if codes.include?(nil)
          #   puts '***********************'
          # end
      end
    end

  private

    def alerts
      framework_nomis_codes.where(code_type: 'alert')
    end

    def personal_care_needs
      framework_nomis_codes.where(code_type: 'personal_care_need')
    end


    def reasonable_adjustments
      framework_nomis_codes.where(code_type: 'reasonable_adjustment')
    end

    def import_personal_care_needs
      @import_personal_care_needs ||= NomisClient::PersonalCareNeeds.get(nomis_offender_numbers: [person.prison_number], personal_care_types: PERSONAL_CARE_NEED_CODES).map do |personal_care_need|
        # next unless personal_care_need['problem_status'] == 'ON'
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

    def import_alerts
      @import_alerts ||= NomisClient::Alerts.get([person.prison_number]).map do |alert|
        # next unless alert['active'] == true && alert['expired'] == false
        FrameworkNomisMapping.new(
          raw_nomis_mapping: alert,
          code_type: 'alert',
          code: alert[:alert_code],
          code_description: alert[:alert_code_description],
          comments: alert[:comment],
          creation_date: alert[:created_at],
          expiry_date: alert[:expires_at],
          )
      end
    end

    def import_reasonable_adjustments
      @import_reasonable_adjustments||= NomisClient::ReasonableAdjustments.get(booking_id: person.latest_nomis_booking_id, reasonable_adjustment_types: reasonable_adjustments.pluck(:code).compact.join(',')).map do |reasonable_adjustment|
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
  end
end
