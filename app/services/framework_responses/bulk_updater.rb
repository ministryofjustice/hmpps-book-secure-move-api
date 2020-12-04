# frozen_string_literal: true

module FrameworkResponses
  class BulkUpdater
    attr_accessor :assessment, :response_values_hash, :errors

    def initialize(assessment, response_values_hash)
      self.assessment = assessment
      self.response_values_hash = response_values_hash
      self.errors = {}
    end

    def call
      updated_responses = build_value_updates_list

      raise BulkUpdateError.new(errors), 'Bulk update error' if errors.any?

      return if updated_responses.empty?

      # Ensure atomic behaviour as we don't want partial inconsistent updates
      ApplicationRecord.retriable_transaction do
        apply_bulk_response_changes(updated_responses)
        apply_assessment_changes
      end
    end

  private

    def build_value_updates_list
      [].tap do |updated_responses|
        validator = ActiveRecord::Import::Validator.new(FrameworkResponse)

        FrameworkResponse.includes(framework_question: %i[framework_flags]).where(assessmentable: assessment).find(response_values_hash.keys).each do |response|
          new_value = response_values_hash[response.id]
          next if response.value == new_value && response.responded == true

          response.value = new_value
          if validator.valid_model?(response)
            updated_responses << response
          else
            errors[response.id] = response.errors.full_messages.first
          end
        rescue FrameworkResponse::ValueTypeError => e
          errors[response.id] = "Value: #{e.message} is incorrect type"
        end
      end
    end

    def apply_bulk_response_changes(updated_responses)
      # Bulk update all modified response values
      FrameworkResponse.import(updated_responses, validate: false, on_duplicate_key_update: { conflict_target: [:id], columns: %i[value_text value_json responded] })

      # Update associated flags for all modified response values
      updated_responses.each(&:rebuild_flags!)

      # Clear dependent values for all modified response values
      FrameworkResponse.clear_dependent_values_and_flags!(updated_responses)
    end

    def apply_assessment_changes
      # Update PER progress with revised responses
      assessment.update_status!
    rescue FiniteMachine::InvalidStateError
      raise ActiveRecord::ReadOnlyRecord, "Can't update framework_responses because assessment is #{assessment.status}"
    end
  end
end
