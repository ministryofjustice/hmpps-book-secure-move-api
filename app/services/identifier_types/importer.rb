# frozen_string_literal: true

module IdentifierTypes
  class Importer
    IDENTIFIER_TYPES = [
      { id: 'police_national_computer', title: 'PNC ID', description: 'Police National Computer ID used by Police' },
      { id: 'prison_number', title: 'Prisoner No', description: 'Prisoner ID used in NOMIS and other systems' },
      { id: 'criminal_records_office', title: 'CRO No', description: 'Criminal Records Office ID used by Police' }
    ].freeze

    def call
      IDENTIFIER_TYPES.each do |attributes|
        IdentifierType
          .find_or_initialize_by(id: attributes[:id])
          .update_attributes(title: attributes[:title], description: attributes[:description])
      end
    end
  end
end
