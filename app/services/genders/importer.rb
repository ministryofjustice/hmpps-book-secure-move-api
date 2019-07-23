# frozen_string_literal: true

module Genders
  class Importer
    VISIBLE_GENDERS = [
      { key: 'female', nomis_code: 'F', title: 'Female' },
      { key: 'male', nomis_code: 'M', title: 'Male' },
      { key: 'trans', nomis_code: nil, title: 'Trans' }
    ].freeze

    attr_accessor :additional_items

    def initialize(additional_items)
      self.additional_items = additional_items
    end

    def call
      VISIBLE_GENDERS.each do |attributes|
        Gender
          .find_or_initialize_by(key: attributes[:key])
          .update(attributes.slice(:title, :disabled_at, :nomis_code))
      end

      additional_items.each do |item|
        gender = Gender.find_or_initialize_by(nomis_code: item[:nomis_code])
        gender.update(item.slice(:title, :key, :disabled_at)) if gender.new_record? || gender.disabled_at.present?
      end
    end
  end
end
