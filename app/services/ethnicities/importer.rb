# frozen_string_literal: true

module Ethnicities
  class Importer
    attr_accessor :items

    HIDDEN_ETHNICITIES = %w[merge].freeze

    def initialize(items)
      self.items = items
    end

    def call
      items.each do |ethnicity|
        record = Ethnicity.find_or_initialize_by(nomis_code: ethnicity[:nomis_code])
        record.update!(
          ethnicity.slice(:title, :key).merge(
            disabled_at: HIDDEN_ETHNICITIES.include?(ethnicity[:key]) ? record.disabled_at || 1.day.ago : nil,
          ),
        )
      end
    end
  end
end
