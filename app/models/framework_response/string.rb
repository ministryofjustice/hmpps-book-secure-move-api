class FrameworkResponse
  class String < FrameworkResponse
    validates :value_json, absence: true
    validates :value_text, presence: true, on: :update, if: -> { framework_question.required }
    validates :value_text, on: :update, inclusion: { in: ->(response) { response.framework_question.options }, if: ->(response) { response.framework_question.options.any? } }

    def self.sti_name
      'string'
    end

    def value
      value_text
    end

    def value=(answer)
      self.value_text = answer
    end
  end
end
