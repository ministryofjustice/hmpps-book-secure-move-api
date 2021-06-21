class FrameworkResponse
  class Array < FrameworkResponse
    validates :value_text, absence: true
    validate :validate_value_inclusion, on: :update

    def value
      value_json.presence || []
    end

    def value=(raw_value)
      super

      self.value_json = raw_value.presence || []
    end

    def option_selected?(option)
      value.include?(option)
    end

  private

    def validate_value_inclusion
      return if errors.present?

      if (invalid_options = value - framework_question.options).any?
        errors.add(:value, "#{invalid_options.join(', ')} are not valid options")
      end
    end

    def value_type_valid?(raw_value)
      raw_value.is_a?(::Array)
    end
  end
end
