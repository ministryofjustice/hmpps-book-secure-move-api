# frozen_string_literal: true

module Genders
  class Importer
    VISIBLE_GENDERS = [
      { key: 'F', title: 'Female', visible: true },
      { key: 'M', title: 'Male', visible: true },
      { key: 'T', title: 'Transexual', visible: true }
    ].freeze

    attr_accessor :additional_items

    def initialize(additional_items)
      self.additional_items = additional_items
    end

    def call
      VISIBLE_GENDERS.each do |attributes|
        Gender
          .find_or_initialize_by(key: attributes[:key])
          .update(attributes.slice(:title, :visible))
      end

      additional_items.each do |item|
        gender = Gender.find_or_initialize_by(key: item[:key])
        gender.update(title: item[:title]) unless gender&.visible?
      end
    end
  end
end
