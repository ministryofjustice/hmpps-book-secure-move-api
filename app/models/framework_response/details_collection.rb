# frozen_string_literal: true

class FrameworkResponse
  class DetailsCollection
    include ActiveModel::Validations

    attr_reader :collection

    validate :details_objects

    def initialize(collection:, question_options: [], details_options: [])
      @collection = Array(collection).map do |item|
        DetailsObject.new(
          attributes: item,
          question_options: question_options,
          details_options: details_options,
        )
      end
    end

    def to_a
      collection
    end

  private

    def details_objects
      errors.add(:collection, :invalid) if collection.any?(&:invalid?)
    end
  end
end
