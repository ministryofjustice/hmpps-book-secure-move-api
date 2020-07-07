class FrameworkResponse
  class String < FrameworkResponse
    validates :value_json, absence: true
    validates :value_text, presence: true, on: :update, if: -> { framework_question.required && parent.nil? }
    validates :value_text, on: :update, inclusion: { in: :question_options }, if: :question_options

    def self.sti_name
      'string'
    end

    def value
      value_text
    end

    def value=(answer)
      self.value_text = answer
    end

    def option_selected?(option)
      value == option
    end

  private

    def question_options
      framework_question.options.presence
    end
  end
end
