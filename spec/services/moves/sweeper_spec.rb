# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Sweeper do
  subject(:sweeper) { described_class.new(brixton_prison, today, input_data) }

  let!(:brixton_prison) { create(:location, nomis_agency_id: 'BXI', location_type: 'prison') }
  let!(:wood_green_court) { create(:location, nomis_agency_id: 'WDGRCC', location_type: 'court') }
  let!(:prisoner_one) { create(:person, nomis_prison_number: 'G3239GV') }
  let!(:prisoner_two) { create(:person, nomis_prison_number: 'G7157AB') }
  let(:today) { Date.civil(2019, 9, 15) }
  let(:yesterday) { Date.civil(2019, 9, 14) }

  let(:input_data) do
    [
      {
        person_nomis_prison_number: 'G3239GV',
        from_location_nomis_agency_id: 'BXI',
        to_location_nomis_agency_id: 'WDGRCC',
        date: '2019-09-15',
        time_due: '2019-08-19T17:00:00',
        status: 'requested',
        nomis_event_id: 468_536_961
      },
      {
        person_nomis_prison_number: 'G7157AB',
        from_location_nomis_agency_id: 'BXI',
        to_location_nomis_agency_id: 'BXI',
        date: '2019-09-15',
        time_due: '2019-08-19T09:00:00',
        status: 'completed',
        nomis_event_id: 487_463_210
      }
    ]
  end

  context 'with no existing records' do
    it 'cancels 0 records' do
      expect { sweeper.call }.to change{ Move.where(status: :cancelled).count }.by(0)
    end
  end

  context 'with one existing record' do
  end

  context 'with one existing record with different attributes' do
  end
end
