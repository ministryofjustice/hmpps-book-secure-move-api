# frozen_string_literal: true

module Ethnicities
  class Importer
    attr_accessor :nomis_data

    def initialize(nomis_data)
      self.nomis_data = nomis_data
    end

    def call
      nomis_data.each do |ethnicity|
        next if ethnicity['activeFlag'] == 'N'

        Ethnicity
          .find_or_initialize_by(key: ethnicity['code'])
          .update_attributes(title: ethnicity['description'])
      end
    end
  end
end
