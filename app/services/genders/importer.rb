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
          .find_or_initialize_by(key: gender['code'])
          .update_attributes(title: gender['description'])
      end
    end
  end
end
