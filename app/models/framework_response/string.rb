class FrameworkResponse
  class String < FrameworkResponse
    validates :value_json, absence: true
    validates :value, inclusion: { in: :question_options }, if: :question_options_and_value_present?

    def value
      value_text
    end

    def value=(raw_value)
      self.value_text = raw_value
    end

    def option_selected?(option)
      value == option
    end

    def question_options
      @question_options ||= framework_question.options
    end

  private

    def question_options_and_value_present?
      question_options.any? && value.present?
    end
  end
end
