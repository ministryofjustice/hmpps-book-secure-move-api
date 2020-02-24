# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Sweeper do
  subject(:sweeper) { described_class.new(locations, today, input_data) }

  let!(:brixton_prison) { create(:location, nomis_agency_id: 'BXI', location_type: 'prison') }
  let(:locations) { [brixton_prison] }
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
        nomis_event_id: 468_536_961,
      },
      {
        person_nomis_prison_number: 'G7157AB',
        from_location_nomis_agency_id: 'BXI',
        to_location_nomis_agency_id: 'BXI',
        date: '2019-09-15',
        time_due: '2019-08-19T09:00:00',
        status: 'completed',
        nomis_event_id: 487_463_210,
      },
    ]
  end

  context 'when initialising' do
    let(:locations) { [brixton_prison, wood_green_court] }

    it 'cleans up locations that are not prisons' do
      expect(sweeper.locations).to eq([brixton_prison])
    end
  end

  context 'with records for newly imported moves' do
    let(:attributes) { input_data.first }

    before do
      input_data.first(2).each do |attributes|
        Move.create!(
          date: attributes[:date],
          time_due: attributes[:time_due],
          nomis_event_ids: [attributes[:nomis_event_id]],
          person: Person.find_by(nomis_prison_number: attributes[:person_nomis_prison_number]),
          from_location: Location.find_by(nomis_agency_id: attributes[:from_location_nomis_agency_id]),
          to_location: Location.find_by(nomis_agency_id: attributes[:to_location_nomis_agency_id]),
          move_agreed: false,
        )
      end
    end

    it 'does not cancel any newly imported moves' do
      expect { sweeper.call }.to change { Move.where(status: :cancelled).count }.by(0)
    end

    context 'with a move with multiple nomis_event_ids' do
      let(:multiple_nomis_ids_move) { Move.find_by(nomis_event_ids: [attributes[:nomis_event_id]]) }

      before do
        multiple_nomis_ids_move.update_attribute(:nomis_event_ids, [attributes[:nomis_event_id], 123_456_789])
      end

      it 'removes the outdated nomis_event_id' do
        sweeper.call
        expect(multiple_nomis_ids_move.reload.nomis_event_ids).to eq([attributes[:nomis_event_id]])
      end
    end

    context 'with a duplicate move and different nomis_event_id' do
      let(:input_data) do
        [
          {
            person_nomis_prison_number: 'G3239GV',
            from_location_nomis_agency_id: 'BXI',
            to_location_nomis_agency_id: 'WDGRCC',
            date: '2019-09-15',
            time_due: '2019-08-19T17:00:00',
            status: 'requested',
            nomis_event_id: 468_536_961,
          },
          {
            person_nomis_prison_number: 'G7157AB',
            from_location_nomis_agency_id: 'BXI',
            to_location_nomis_agency_id: 'BXI',
            date: '2019-09-15',
            time_due: '2019-08-19T09:00:00',
            status: 'completed',
            nomis_event_id: 487_463_210,
          },
          {
            person_nomis_prison_number: 'G3239GV',
            from_location_nomis_agency_id: 'BXI',
            to_location_nomis_agency_id: 'WDGRCC',
            date: '2019-09-15',
            time_due: '2019-08-19T17:00:00',
            status: 'requested',
            nomis_event_id: 468_536_962,
          },
        ]
      end

      let(:move) { Move.find_by('? = ANY(nomis_event_ids)', attributes[:nomis_event_id]) }

      it 'merges two moves together' do
        sweeper.call
        expect(move.reload.nomis_event_ids.count).to eq(2)
      end

      it 'adds the new nomis_event_id to nomis_event_ids' do
        sweeper.call
        expect(move.reload.nomis_event_ids).to include(
          input_data.first[:nomis_event_id], input_data.last[:nomis_event_id]
        )
      end
    end

    context 'with an outdated move' do
      let(:input_data) do
        [
          {
            person_nomis_prison_number: 'G3239GV',
            from_location_nomis_agency_id: 'BXI',
            to_location_nomis_agency_id: 'WDGRCC',
            date: '2019-09-15',
            time_due: '2019-08-19T17:00:00',
            status: 'requested',
            nomis_event_id: 468_536_961,
          },
        ]
      end
      let(:outdated_move) do
        Move.find_by(from_location: brixton_prison, to_location: brixton_prison, person: prisoner_two)
      end

      before do
        Move.create!(
          date: '2019-09-15',
          from_location: brixton_prison,
          to_location: brixton_prison,
          person: prisoner_two,
          status: 'requested',
          time_due: '2019-08-19 08:00:00',
          nomis_event_ids: [487_463_210],
          move_agreed: false,
        )
      end

      it 'empties the nomis_event_ids array' do
        sweeper.call
        expect(outdated_move.reload.nomis_event_ids).to be_empty
      end

      it 'cancels the outdated move' do
        sweeper.call
        expect(outdated_move.reload.status).to eq('cancelled')
      end
    end
  end
end
