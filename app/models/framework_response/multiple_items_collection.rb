# frozen_string_literal: true

class FrameworkResponse
  class MultipleItemsCollection
    include ActiveModel::Validations

    attr_reader :collection

    validate :multiple_item_objects

    def initialize(collection:, person_escort_record:, questions: [])
      @collection = Array(collection).map do |item|
        MultipleItemObject.new(
          attributes: item,
          questions: questions,
          person_escort_record: person_escort_record,
        )
      end
    end

    def to_a
      collection
    end

  private

    def multiple_item_objects
      return unless collection.any?(&:invalid?)

      collection.each_with_index do |object, index|
        object.errors.each do |key, value|
          errors.add("items[#{index}].#{key}", value)
        end
      end
    end
  end
end
