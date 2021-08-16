# frozen_string_literal: true

module Genders
  class Importer
    VISIBLE_GENDERS = [
      { key: 'female', nomis_code: 'F', title: 'Female', disabled_at: nil },
      { key: 'male', nomis_code: 'M', title: 'Male', disabled_at: nil },
      { key: 'trans', nomis_code: nil, title: 'Trans', disabled_at: nil },
    ].freeze

    attr_accessor :additional_items

    def initialize(additional_items)
      self.additional_items = additional_items
    end

    def call
      import_visible_genders
      import_nomis_genders
    end

    def import_visible_genders
      VISIBLE_GENDERS.each do |attributes|
        Gender
          .find_or_initialize_by(key: attributes[:key])
          .update(attributes.slice(:title, :nomis_code, :disabled_at))
      end
    end

    def import_nomis_genders
      additional_items.each do |item|
        gender = Gender.find_or_initialize_by(nomis_code: item[:nomis_code])
        next if VISIBLE_GENDERS.map { |visible_gender| visible_gender[:key] }.include?(gender.key)

        gender
          .update!(item.slice(:title, :key)
          .merge(disabled_at: gender.disabled_at || 1.day.ago))
      end
    end
  end
end
