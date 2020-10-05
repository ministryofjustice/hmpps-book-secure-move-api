# frozen_string_literal: true

module FrameworkNomisMappings
  class Importer
    attr_reader :person, :framework_responses, :framework_nomis_codes
    def initialize(person:, framework_responses:, framework_nomis_codes:)
      @person = person
      @framework_responses = framework_responses
      @framework_nomis_codes = framework_nomis_codes
    end

    def call
      return unless person && framework_responses.any? && framework_nomis_codes.any?

      ActiveRecord::Base.transaction do
        return unless persist_framework_nomis_mappings.any?

        framework_responses.includes(:framework_nomis_mappings).each do |response|
          nomis_code_ids = responses_to_codes[response.id]&.pluck(:nomis_code_id)
          response.framework_nomis_mappings = nomis_code_ids_to_mappings.slice(*nomis_code_ids).values.flatten
        end
      end
    end

  private

    def persist_framework_nomis_mappings
      @persist_framework_nomis_mappings ||= begin
        mappings = alert_mappings + personal_care_need_mappings + reasonable_adjust_mappings
        # TODO: log any validation failures
        import = FrameworkNomisMapping.import(mappings, all_or_none: true)

        FrameworkNomisMapping.where(id: import.ids)
      end
    end

    def alert_mappings
      FrameworkNomisMappings::Alerts.new(prison_number: person.prison_number).call
    end

    def personal_care_need_mappings
      FrameworkNomisMappings::PersonalCareNeeds.new(prison_number: person.prison_number).call
    end

    def reasonable_adjust_mappings
      FrameworkNomisMappings::ReasonableAdjustments.new(
        booking_id: person.latest_nomis_booking_id,
        nomis_codes: grouped_framework_nomis_codes['reasonable_adjustment'],
      ).call
    end

    def grouped_framework_nomis_codes
      framework_nomis_codes.group_by(&:code_type)
    end

    def fallback_nomis_codes
      @fallback_nomis_codes ||= framework_nomis_codes.select(&:fallback?)
    end

    def nomis_code_ids_to_mappings
      @nomis_code_ids_to_mappings ||= begin
        persist_framework_nomis_mappings.each_with_object({}) do |mapping, hash|
          mapping_nomis_codes = framework_nomis_codes.select { |nomis_code| nomis_code.code == mapping.code && nomis_code.code_type == mapping.code_type }
          mapping_nomis_fallback = fallback_nomis_codes.find { |fallback| fallback.code_type == mapping.code_type }

          if mapping_nomis_codes.any?
            mapping_nomis_codes.each do |nomis_code|
              hash[nomis_code.id] = hash[nomis_code.id].to_a + [mapping]
            end
          elsif mapping_nomis_fallback
            hash[mapping_nomis_fallback.id] = hash[mapping_nomis_fallback.id].to_a + [mapping]
          end
        end
      end
    end

    def responses_to_codes
      @responses_to_codes ||= framework_responses.joins(:framework_nomis_codes).select('framework_responses.id as id, framework_nomis_codes.id as nomis_code_id').group_by(&:id)
    end
  end
end
