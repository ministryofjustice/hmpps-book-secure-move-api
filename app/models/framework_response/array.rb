class FrameworkResponse
  class Array < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_question_options, on: :update

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

    def validate_question_options
      if (o = (value - question_options))
        o.each do |option|
          errors.add(:value, option + " is not a valid option")
        end
      end
    end
  end
end
