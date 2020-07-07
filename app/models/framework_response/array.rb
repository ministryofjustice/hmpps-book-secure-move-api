class FrameworkResponse
  class Array < FrameworkResponse
    validates :value_text, absence: true
    validates :value_json, presence: true, on: :update, if: -> { framework_question.required && parent.nil? }
    validates :value_json, on: :update, inclusion: { in: :question_options }, if: :question_options

    def self.sti_name
      'array'
    end

    def value
      value_json.presence || []
    end

    def value=(answer)
      self.value_json = answer.presence || []
    end

    def option_selected?(option)
      value.include?(option)
    end

  private

    def question_options
      framework_question.options.presence
    end
  end
end
