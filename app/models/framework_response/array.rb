class FrameworkResponse
  class Array < FrameworkResponse
    validate :validate_array_type
    validates :value_text, absence: true
    validate :validate_value_inclusion, on: :update

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

    def validate_value_inclusion
      return if errors.present?

      if (invalid_options = value - framework_question.options).any?
        errors.add(:value, invalid_options.join(', ') + ' are not valid options')
      end
    end

    def validate_array_type
      unless value.is_a?(::Array)
        errors.add(:value, 'is incorrect type')
      end
    end
  end
end
