# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:move_event_one) { 468_536_961 }
  let(:move_event_two) { 487_463_210 }
  let(:input_data) do
    [
      {
        person_nomis_prison_number: 'G3239GV',
        from_location_nomis_agency_id: 'BXI',
        to_location_nomis_agency_id: 'WDGRCC',
        date: '2019-08-19',
        time_due: '2019-08-19T17:00:00',
        status: 'requested',
        nomis_event_id: move_event_one
      },
      {
        person_nomis_prison_number: 'G7157AB',
        from_location_nomis_agency_id: 'BXI',
        to_location_nomis_agency_id: 'BXI',
        date: '2019-08-19',
        time_due: '2019-08-19T09:00:00',
        status: 'completed',
        nomis_event_id: move_event_two
      }
    ]
  end

  let!(:brixton_prison) { create(:location, nomis_agency_id: 'BXI', location_type: 'prison') }
  let!(:wood_green_court) { create(:location, nomis_agency_id: 'WDGRCC', location_type: 'court') }
  let!(:prisoner_one) { create(:person, nomis_prison_number: 'G3239GV') }
  let!(:prisoner_two) { create(:person, nomis_prison_number: 'G7157AB') }
  let!(:profile_one) { create(:profile, person: prisoner_one) }
  let!(:profile_two) { create(:profile, person: prisoner_two) }

  let(:people_importer) { instance_double('People::Importer', call: true) }
  let(:alerts_importer) { instance_double('Alerts::Importer', call: true) }
  let(:offender_numbers_response) { [{ offender_no: 'G3239GV' }, { offender_no: 'G7157AB' }] }
  let(:personal_care_needs_response) do
    [{ offender_no: 'G3239GV', problem_type: 'MATSTAT', problem_code: 'ACCU9' },
     { offender_no: 'G7157AB', problem_type: 'MATSTAT', problem_code: 'ACCU9' }]
  end

  before do
    # People importer should do nothing, as both people already exist
    allow(NomisClient::People).to receive(:get).and_return(offender_numbers_response)
    allow(NomisClient::Alerts).to receive(:get).and_return(offender_numbers_response)
    allow(NomisClient::PersonalCareNeeds).to receive(:get).and_return(personal_care_needs_response)
    allow(People::Importer).to receive(:new).and_return(people_importer)
    allow(Alerts::Importer).to receive(:new).and_return(alerts_importer)
    # create a fallback question so that the PersonalCareNeeds importer can use it.
    create(:assessment_question, :fallback)
    create(:nomis_alert, type_code: 'MATSTAT', code: 'ACCU9')
  end

  it 'calls the People::Importer service twice' do
    importer.call
    expect(people_importer).to have_received(:call).twice
  end

  it 'calls the Alerts::Importer service twice' do
    importer.call
    expect(alerts_importer).to have_received(:call).twice
  end

  context 'with no existing records' do
    let(:move) { Move.find_by_nomis_event_ids([move_event_one]) }
    let(:completed_move) { Move.find_by_nomis_event_ids([move_event_two]) }

    it 'creates 2 moves' do
      expect { importer.call }.to change(Move, :count).by(2)
    end

    it 'sets the date of the move' do
      importer.call
      expect(move.date).to eq Date.parse('2019-08-19')
    end

    it 'sets the time_due of the move' do
      importer.call
      expect(move.time_due).to eq Time.zone.parse('2019-08-19T17:00:00')
    end

    it 'sets the from_location of the move' do
      importer.call
      expect(move.from_location).to eq brixton_prison
    end

    it 'sets the to_location of the move' do
      importer.call
      expect(move.to_location).to eq wood_green_court
    end

    it 'sets the status of the move' do
      importer.call
      expect(move.status).to eq 'requested'
    end

    it 'sets the status of the completed move' do
      importer.call
      expect(completed_move.status).to eq 'completed'
    end

    it 'sets the person of the move' do
      importer.call
      expect(move.person).to eq prisoner_one
    end
  end

  context 'with one existing record' do
    let!(:move) { create(:move, nomis_event_ids: [move_event_one]) }

    it 'creates 1 move' do
      expect { importer.call }.to change(Move, :count).by(1)
    end

    it 'keeps people the same' do
      expect { importer.call }.not_to change(Person, :count)
    end

    it 'keeps profiles the same' do
      expect { importer.call }.not_to change(Profile, :count)
    end

    it 'imports 2 assessment answers, 1 for for each profile' do
      expect do
        importer.call
      end.to change { Profile.all.map(&:assessment_answers).map(&:size).reduce(:+) }.by(2)
    end
  end

  context 'with one existing record with different attributes' do
    let(:time_due) { Time.zone.parse('2019-08-19T09:00:00') }
    let!(:move) { create(:move, nomis_event_ids: [move_event_one], time_due: time_due) }

    it 'updates the field that is different' do
      importer.call
      expect(Move.find_by_nomis_event_ids([move_event_one]).time_due).to eq Time.zone.parse('2019-08-19T17:00:00')
    end
  end
end
