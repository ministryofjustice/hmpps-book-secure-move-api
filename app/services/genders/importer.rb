# frozen_string_literal: true

module Genders
  class Importer
    attr_accessor :nomis_data

    def initialize(nomis_data)
      self.nomis_data = nomis_data
    end

    def call
      nomis_data.each do |gender|
        next if gender['activeFlag'] == 'N'

        Gender
          .create_with(title: gender['description'])
          .find_or_create_by(key: gender['code'])
      end
    end
  end
end
