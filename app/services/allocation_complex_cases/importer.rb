# frozen_string_literal: true

module AllocationComplexCases
  class Importer
    COMPLEX_CASES = [
      { key: 'hold_separately', title: 'Segregated prisoners' },
      { key: 'self_harm', title: 'Self harm / prisoners on ACCT' },
      { key: 'mental_health_issue', title: 'Mental health issues' },
      { key: 'under_drug_treatment', title: 'Integrated Drug Treatment System' },
    ].freeze

    def call
      COMPLEX_CASES.each do |attributes|
        AllocationComplexCase
          .find_or_initialize_by(key: attributes[:key])
          .update(title: attributes[:title])
      end
    end
  end
end
