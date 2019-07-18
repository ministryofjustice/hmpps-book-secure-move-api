# frozen_string_literal: true

module Genders
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      items.each do |gender|
        next if gender['activeFlag'] == 'N'

        Gender
          .find_or_initialize_by(key: gender[:key])
          .update(title: gender[:title])
      end
    end
  end
end
