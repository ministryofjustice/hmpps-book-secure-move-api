class FrameworkResponse
  class Array < FrameworkResponse
    validates :value_text, absence: true
    validates :value_json, presence: true, on: :update, if: -> { framework_question.required }
    validates :value_json, on: :update, inclusion: { in: ->(response) { response.framework_question.options }, if: ->(response) { response.framework_question.options.any? } }

    def self.sti_name
      'array'
    end

    def value
      value_json.presence || []
    end

    def value=(answer)
      self.value_json = answer.presence || []
    end
  end
end
