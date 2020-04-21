# frozen_string_literal: true

module ComplexCases
  class Importer
    COMPLEX_CASES = [
      { key: 'segregated', title: 'Segregated prisoners' },
      { key: 'acct', title: 'Self harm / prisoners on ACCT' },
      { key: 'mental', title: 'Mental health issues' },
      { key: 'drugs', title: 'Integrated Drug Treatment System' },
    ].freeze

    def call
      COMPLEX_CASES.each do |attributes|
        ComplexCase
          .find_or_initialize_by(key: attributes[:key])
          .update(title: attributes[:title])
      end
    end
  end
end
