class FrameworkResponse
  class String < FrameworkResponse
    validates :value_json, absence: true
    validates :value, inclusion: { in: :question_options }, if: ->(response) { response.question_options && response.value.present? }

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
      @question_options ||= framework_question.options.presence
    end
  end
end
