class FrameworkResponse
  class Collection < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_details_collection, on: :update, if: -> { response_details }

    def value
      value_json.presence || []
    end

    def value=(raw_value)
      self.value_json =
        if response_details
          details_collection(raw_value).to_a
        else
          self.value_json = raw_value.presence || []
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
      errors.add(:value, :invalid) if details_collection(value).invalid?
    end

    def response_details
      @response_details ||= framework_question.followup_comment
    end
  end
end
