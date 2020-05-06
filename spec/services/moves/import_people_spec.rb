# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ImportPeople do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [prisoner_one.nomis_prison_number]
  end

  let!(:brixton_prison) { create(:location, nomis_agency_id: 'BXI', location_type: 'prison') }
  let!(:wood_green_court) { create(:location, nomis_agency_id: 'WDGRCC', location_type: 'court') }
  let!(:prisoner_one) { create(:person, :nomis_synced) }
  let!(:prisoner_two) { create(:person, :nomis_synced) }
  let!(:profile_one) { create(:profile, person: prisoner_one) }
  let!(:profile_two) { create(:profile, person: prisoner_two) }

  let(:alerts_response) do
    [{ offender_no: prisoner_one.nomis_prison_number, alert_code: 'ACCU9', alert_type: 'MATSTAT' },
     { offender_no: prisoner_two.nomis_prison_number, alert_code: 'ACCU9', alert_type: 'MATSTAT' },
     { offender_no: prisoner_two.nomis_prison_number, alert_code: 'ACCU4', alert_type: 'MATSTAT' }]
  end
  let(:offender_numbers_response) { [{ offender_no: 'G3239GV' }, { offender_no: 'G7157AB' }] }
  let(:prison_numbers_response) do
    [{ prison_number: prisoner_one.nomis_prison_number, first_name: 'Bob' },
     { prison_number: prisoner_two.nomis_prison_number, first_name: 'Bob' }]
  end
  let(:personal_care_needs_response) do
    [{ offender_no: prisoner_one.nomis_prison_number, problem_type: 'MATSTAT', problem_code: 'ACCU9' },
     { offender_no: prisoner_two.nomis_prison_number, problem_type: 'MATSTAT', problem_code: 'ACCU9' },
     { offender_no: prisoner_two.nomis_prison_number, problem_type: 'MATSTAT', problem_code: 'ACCU4' }]
  end

  before do
    allow(NomisClient::People).to receive(:get).and_return(prison_numbers_response)
    allow(NomisClient::Alerts).to receive(:get).and_return(alerts_response)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)
    # create fallback questions for PersonalCareNeeds importer and Alerts importer
    create(:assessment_question, :care_needs_fallback)
    create(:assessment_question, :alerts_fallback)
  end

  context 'with one existing record' do
    it 'keeps people the same' do
      expect { importer.call }.not_to change(Person, :count)
    end

    it 'keeps profiles the same' do
      expect { importer.call }.not_to change(Profile, :count)
    end
  end
end
