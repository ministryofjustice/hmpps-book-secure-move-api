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

  private

    def details_collection(collection)
      DetailsCollection.new(
        collection: collection,
        question_options: framework_question.options,
        details_options: framework_question.followup_comment_options,
      )
    end

    def multiple_items_collection(collection)
      MultipleItemsCollection.new(
        collection: collection,
        questions: framework_question.dependents,
        person_escort_record: person_escort_record,
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
  end
end
