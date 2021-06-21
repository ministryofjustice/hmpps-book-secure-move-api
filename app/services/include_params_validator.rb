# frozen_string_literal: true

class IncludeParamsValidator
  include ActiveModel::Validations

  attr_reader :relationships, :supported_relationships

  validates_each :relationships, allow_blank: true do |record, _attr, values|
    unsupported_values = values - record.splatted_supported_relationships

    unless unsupported_values.empty?
      record.errors.add 'Bad request', "#{unsupported_values} is not supported. Valid values are: #{record.splatted_supported_relationships}"
    end
  end

  def initialize(relationships, supported_relationships)
    @relationships = relationships
    @supported_relationships = supported_relationships
  end

  def fully_validate!
    raise ValidationError, self if invalid?
  end

  # Active Model Serializers return all members of a nested chain
  #
  # For example:
  #   'foo.bar.baz' is equivalent to ['foo', 'foo.bar', 'foo.bar.baz']
  #
  # To reflect this behaviour in the validation we need to support all variations
  # of nested chains by preformatting them in this validator.
  def splatted_supported_relationships
    splatted_supported_relationships = Set.new

    supported_relationships.each do |chain|
      split_chain = chain.split('.')
      split_chain.each_with_index do |_, index|
        splatted_supported_relationships << split_chain[0..index].join('.')
      end
    end

    splatted_supported_relationships.to_a
  end

  class ValidationError < StandardError
    def initialize(validator)
      @validator = validator
      super()
    end

    delegate :errors, to: :@validator
  end
end
