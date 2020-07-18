class FrameworkResponse
  class Collection < FrameworkResponse
    validate :validate_collection_type
    validates :value_text, absence: true
    validate :validate_details_collection, on: :update, if: -> { response_details }

    def value
      value_json.presence || []
    end

    def value=(raw_value)
      self.value_json =
        if response_details && collection_type_valid?(raw_value)
          details_collection(raw_value).to_a
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

    def validate_details_collection
      return if errors.present?

      validated_collection = details_collection(value)
      if validated_collection.invalid?
        errors.merge!(validated_collection.errors)
      end
    end

    def response_details
      @response_details ||= framework_question.followup_comment
    end

    def validate_collection_type
      unless collection_type_valid?(value)
        errors.add(:value, 'is incorrect type')
      end
    end

    def collection_type_valid?(collection)
      collection.is_a?(::Array) && collection.all?(::Hash)
    end
  end
end
