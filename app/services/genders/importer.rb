# frozen_string_literal: true

module Genders
  class Importer
    VISIBLE_GENDERS = [
      { key: 'female', nomis_code: 'F', title: 'Female', visible: true },
      { key: 'male', nomis_code: 'M', title: 'Male', visible: true },
      { key: 'transexual', nomis_code: nil, title: 'Transexual', visible: true }
    ].freeze

    attr_accessor :additional_items

    def initialize(additional_items)
      self.additional_items = additional_items
    end

    def call
      VISIBLE_GENDERS.each do |attributes|
        Gender
          .find_or_initialize_by(key: attributes[:key])
          .update(attributes.slice(:title, :visible, :nomis_code))
      end

      additional_items.each do |item|
        gender = Gender.find_or_initialize_by(nomis_code: item[:nomis_code])
        gender.update(item.slice(:title, :key)) unless gender&.visible?
      end
    end
  end
end
