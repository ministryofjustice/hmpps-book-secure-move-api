class FrameworkResponse
  class Array < FrameworkResponse
    validates :value_text, absence: true
    validates :value_json, on: :update, inclusion: { in: :question_options }, if: :question_options

    def value
      value_json.presence || []
    end

    def value=(raw_value)
      self.value_json = raw_value.presence || []
    end

    def option_selected?(option)
      value.include?(option)
    end

  private

    def question_options
      @question_options ||= framework_question.options.presence
    end
  end
end
