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
          .create_with(title: ethnicity['description'])
          .find_or_create_by(key: ethnicity['code'])
      end
    end
  end
end
