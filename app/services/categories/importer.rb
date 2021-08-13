# frozen_string_literal: true

module Categories
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items.with_indifferent_access
    end

    def call
      items.each do |key, details|
        category = Category.find_or_initialize_by(key: key.to_s)
        category.locations = Location.where(nomis_agency_id: details[:locations])
        category.update!(title: details[:title], move_supported: details[:move_supported])
      end
    end
  end
end
