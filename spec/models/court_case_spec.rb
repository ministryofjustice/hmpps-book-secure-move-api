# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourtCase do
  describe '#build_from_nomis' do
    let(:nomis_court_case) { JSON.parse(file_fixture('nomis_get_court_cases_200.json').read).first }

    it 'builds a CourtCase from Nomis response' do
      court_case = described_class.new.build_from_nomis(nomis_court_case)

      expect(court_case.id).to eq(nomis_court_case['id'])
      expect(court_case.begin_date).to eq(nomis_court_case['beginDate'])
    end
  end
end
