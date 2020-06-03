# frozen_string_literal: true

class IncludeParamsValidator
  include ActiveModel::Validations

  attr_reader :relationships, :supported_relationships

  validates_each :relationships, allow_blank: true do |record, _attr, values|
    unsupported_values = values - record.supported_relationships

    unless unsupported_values.empty?
      record.errors.add 'Bad request', "#{unsupported_values} is not supported. Valid values are: #{record.supported_relationships}"
    end
  end

  def initialize(relationships, supported_relationships)
    @relationships = relationships
    @supported_relationships = supported_relationships
  end

  def fully_validate!
    raise ValidationError, self if invalid?
  end

  class ValidationError < StandardError
    def initialize(validator)
      @validator = validator
    end

    delegate :errors, to: :@validator
  end
end
