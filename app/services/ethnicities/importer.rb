# frozen_string_literal: true

module Ethnicities
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      items.each do |ethnicity|
        Ethnicity
          .find_or_initialize_by(key: ethnicity[:key])
          .update(title: ethnicity[:title])
      end
    end
  end
end
