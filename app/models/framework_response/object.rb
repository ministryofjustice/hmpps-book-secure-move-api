class FrameworkResponse
  class Object < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_details_object, on: :update, if: -> { response_details }

    def value
      value_json.presence || {}
    end

    def value=(raw_value)
      self.value_json =
        if response_details
          details_object(attributes: raw_value)
        else
          raw_value.presence || {}
        end
    end

    def option_selected?(option)
      value['option'] == option
    end

  private

    def details_object(attributes:)
      DetailsObject.new(
        attributes: attributes,
        question_options: framework_question.options,
        details_options: framework_question.followup_comment_options,
      )
    end

    def response_details
      @response_details ||= framework_question.followup_comment
    end

    def validate_details_object
      # TODO: Add proper validation messages
      errors.add(:value, :invalid) if details_object(attributes: value).invalid?
    end
  end
end
