# frozen_string_literal: true

module FrameworkNomisMappings
  class Importer
    attr_reader :person, :assessmentable, :framework_responses, :framework_nomis_codes

    def initialize(assessmentable:)
      @assessmentable = assessmentable
      @person = assessmentable&.profile&.person
      @framework_responses = assessmentable&.framework_responses
      @framework_nomis_codes = framework_responses&.includes(:framework_nomis_codes)&.flat_map(&:framework_nomis_codes)
    end

    def call
      return unless assessmentable && framework_responses.any? && framework_nomis_codes.any?

      ApplicationRecord.retriable_transaction do
        return unless persist_framework_nomis_mappings.any?

        framework_responses.includes(:framework_nomis_mappings).each do |response|
          nomis_code_ids = responses_to_codes[response.id]&.pluck(:nomis_code_id)
          response.framework_nomis_mappings = nomis_code_ids_to_mappings.slice(*nomis_code_ids).values.flatten
        end

        assessmentable.update!(nomis_sync_status:)
      end
    end

  private

    def nomis_sync_status
      [
        alert_mappings.nomis_sync_status,
        assessment_mappings.nomis_sync_status,
        contact_mappings.nomis_sync_status,
        personal_care_need_mappings.nomis_sync_status,
        reasonable_adjust_mappings.nomis_sync_status,
      ]
    end

    def persist_framework_nomis_mappings
      @persist_framework_nomis_mappings ||= begin
        mappings = alert_mappings.call + assessment_mappings.call + contact_mappings.call + personal_care_need_mappings.call + reasonable_adjust_mappings.call
        import = FrameworkNomisMapping.import(mappings, all_or_none: true)

        if import.failed_instances.any?
          log_exception(
            'FrameworkNomisMapping import validation Error',
            extra: { error_messages: import.failed_instances.map { |mapping| mapping.errors.messages } },
          )
        end

        FrameworkNomisMapping.where(id: import.ids)
      end
    end

    def alert_mappings
      @alert_mappings ||= FrameworkNomisMappings::Alerts.new(prison_number: person.prison_number)
    end

    def assessment_mappings
      @assessment_mappings ||= FrameworkNomisMappings::Assessments.new(booking_id: person.latest_nomis_booking_id)
    end

    def contact_mappings
      @contact_mappings ||= FrameworkNomisMappings::Contacts.new(booking_id: person.latest_nomis_booking_id)
    end

    def personal_care_need_mappings
      @personal_care_need_mappings ||= FrameworkNomisMappings::PersonalCareNeeds.new(prison_number: person.prison_number)
    end

    def reasonable_adjust_mappings
      @reasonable_adjust_mappings ||= FrameworkNomisMappings::ReasonableAdjustments.new(
        booking_id: person.latest_nomis_booking_id,
        nomis_codes: grouped_framework_nomis_codes['reasonable_adjustment'],
      )
    end

    def grouped_framework_nomis_codes
      framework_nomis_codes.group_by(&:code_type)
    end

    def fallback_nomis_codes
      @fallback_nomis_codes ||= framework_nomis_codes.select(&:fallback?)
    end

    def nomis_code_ids_to_mappings
      @nomis_code_ids_to_mappings ||= persist_framework_nomis_mappings.each_with_object({}) do |mapping, hash|
        mapping_nomis_codes = framework_nomis_codes.select { |nomis_code| nomis_code.code == mapping.code && nomis_code.code_type == mapping.code_type }
        mapping_nomis_fallback = fallback_nomis_codes.find { |fallback| fallback.code_type == mapping.code_type }

        if mapping_nomis_codes.any?
          mapping_nomis_codes.each do |nomis_code|
            hash[nomis_code.id] = hash[nomis_code.id].to_a + [mapping]
          end
        elsif mapping_nomis_fallback
          hash[mapping_nomis_fallback.id] = hash[mapping_nomis_fallback.id].to_a + [mapping]
          log_exception(
            'New NOMIS codes imported',
            tags: { nomis_code: mapping.code, nomis_type: mapping_nomis_fallback.code_type },
            level: :warning,
          )
        end
      end
    end

    def responses_to_codes
      @responses_to_codes ||= framework_responses.joins(:framework_nomis_codes).select('framework_responses.id as id, framework_nomis_codes.id as nomis_code_id').group_by(&:id)
    end

    def log_exception(description, tags: {}, extra: {}, level: :error)
      Sentry.capture_message(
        description,
        tags:,
        extra: { assessmentable_id: assessmentable&.id }.merge(extra),
        level:,
      )
    end
  end
end
