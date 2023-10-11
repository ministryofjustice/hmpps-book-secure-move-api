class FrameworkResponse
  class Object < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_details_object, on: :update, if: -> { response_details }

    def value
      value_json.presence || {}
    end

    def value=(raw_value)
      super

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
      details_options = framework_nomis_mappings.any? ? [] : framework_question.followup_comment_options
      DetailsObject.new(
        attributes:,
        question_options: framework_question.options,
        details_options:,
      )
    end

    def response_details
      @response_details ||= framework_question.followup_comment
    end

    def validate_details_object
      return if errors.present?

      validated_object = details_object(attributes: value)
      if validated_object.invalid?
        errors.merge!(validated_object.errors)
      end
    end

    def value_type_valid?(raw_value)
      raw_value.is_a?(::Hash)
    end
  end
end
