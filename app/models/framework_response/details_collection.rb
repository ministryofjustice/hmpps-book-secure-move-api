# frozen_string_literal: true

class FrameworkResponse
  class DetailsCollection
    include ActiveModel::Validations

    attr_reader :collection

    validate :details_objects
    validate :details_option_uniqueness

    def initialize(collection:, question_options: [], details_options: [])
      @collection = Array(collection).map do |item|
        DetailsObject.new(
          attributes: item,
          question_options:,
          details_options:,
        )
      end
    end

    def to_a
      collection
    end

  private

    def details_objects
      return unless collection.any?(&:invalid?)

      collection.each do |detail_object|
        errors.merge!(detail_object.errors)
      end
    end

    def details_option_uniqueness
      options = collection.map(&:option)
      if options.size != options.uniq.size
        errors.add(:option, 'Duplicate options selected')
      end
    end
  end
end
