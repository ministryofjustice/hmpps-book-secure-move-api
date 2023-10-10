class FrameworkResponse
  class Collection < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_details_collection, on: :update, if: -> { response_details }
    validate :validate_multiple_items_collection, on: :update, if: -> { multiple_items? }

    def value
      value_json&.delete_if(&:empty?)
      value_json.presence || []
    end

    def value=(raw_value)
      super

      self.value_json =
        if response_details
          details_collection(raw_value).to_a
        elsif multiple_items?
          multiple_items_collection(raw_value).to_a
        else
          raw_value.presence || []
        end
    end

    def option_selected?(option)
      value.map { |v| v['option'] }.include?(option)
    end

    def prefill_value
      return super unless multiple_items?

      value.each_with_object([]) do |item, prefill_items|
        item['responses'] = responses_to_prefill(item['responses'])

        prefill_items << item unless item['responses'].empty?
      end
    end

  private

    def details_collection(collection)
      details_options = framework_nomis_mappings.any? ? [] : framework_question.followup_comment_options
      DetailsCollection.new(
        collection:,
        question_options: framework_question.options,
        details_options:,
      )
    end

    def multiple_items_collection(collection)
      MultipleItemsCollection.new(
        collection:,
        questions: framework_question.dependents,
        assessmentable:,
      )
    end

    def validate_details_collection
      return if errors.present?

      validated_collection = details_collection(value)
      if validated_collection.invalid?
        errors.merge!(validated_collection.errors)
      end
    end

    def validate_multiple_items_collection
      return if errors.present?

      validated_collection = multiple_items_collection(value)
      if validated_collection.invalid?
        errors.merge!(validated_collection.errors)
      end
    end

    def response_details
      @response_details ||= framework_question.followup_comment
    end

    def multiple_items?
      framework_question.question_type == 'add_multiple_items'
    end

    def value_type_valid?(raw_value)
      raw_value.is_a?(::Array) && raw_value.all?(::Hash)
    end

    def responses_to_prefill(responses)
      responses.select do |response|
        question = framework_question.dependents.find { |dependent| dependent.id == response['framework_question_id'] }
        question&.prefill
      end
    end
  end
end
