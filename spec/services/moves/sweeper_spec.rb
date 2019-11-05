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

  context 'with records for newly imported moves' do
    before do
      input_data.each do |attributes|
        Move.create!(
          date: attributes[:date],
          time_due: attributes[:time_due],
          nomis_event_ids: [attributes[:nomis_event_id]],
          person: Person.find_by(nomis_prison_number: attributes[:person_nomis_prison_number]),
          from_location: Location.find_by(nomis_agency_id: attributes[:from_location_nomis_agency_id]),
          to_location: Location.find_by(nomis_agency_id: attributes[:to_location_nomis_agency_id])
        )
      end
    end

    it 'does not cancel any newly imported moves' do
      expect { sweeper.call }.to change { Move.where(status: :cancelled).count }.by(0)
    end

    context 'with an outdated move' do
      let(:attributes) { input_data.first }
      let!(:outdated_move) do
        Move.create!(
          date: attributes[:date],
          time_due: attributes[:time_due],
          nomis_event_ids: [487_463_209],
          person: Person.find_by(nomis_prison_number: attributes[:person_nomis_prison_number]),
          from_location: Location.find_by(nomis_agency_id: attributes[:from_location_nomis_agency_id]),
          to_location: Location.find_by(nomis_agency_id: attributes[:to_location_nomis_agency_id])
        )
      end

      context 'with an additional move on a different date' do
        let!(:move_yesterday) do
          Move.create!(
            date: yesterday,
            time_due: attributes[:time_due],
            nomis_event_ids: [487_463_208],
            person: Person.find_by(nomis_prison_number: attributes[:person_nomis_prison_number]),
            from_location: Location.find_by(nomis_agency_id: attributes[:from_location_nomis_agency_id]),
            to_location: Location.find_by(nomis_agency_id: attributes[:to_location_nomis_agency_id])
          )
        end

        it 'cancels one move' do
          expect { sweeper.call }.to change { Move.where(status: :cancelled).count }.by(1)
        end

        it 'cancels the move that did match by date' do
          sweeper.call
          expect(outdated_move.reload.status).to eq 'cancelled'
        end

        it 'leaves the move that did not match by date' do
          sweeper.call
          expect(move_yesterday.reload.status).to eq 'requested'
        end
      end

      context 'with an additional for a different location' do
        let!(:court_move) do
          Move.create!(
            date: attributes[:date],
            time_due: attributes[:time_due],
            nomis_event_ids: [],
            person: Person.find_by(nomis_prison_number: attributes[:person_nomis_prison_number]),
            from_location: wood_green_court,
            to_location: Location.find_by(nomis_agency_id: attributes[:to_location_nomis_agency_id])
          )
        end

        it 'cancels one move' do
          expect { sweeper.call }.to change { Move.where(status: :cancelled).count }.by(1)
        end

        it 'cancels the move that did match' do
          sweeper.call
          expect(outdated_move.reload.status).to eq 'cancelled'
        end

        it 'leaves the move that did not match by location' do
          sweeper.call
          expect(court_move.reload.status).to eq 'requested'
        end
      end

      context 'with multiple locations' do
        let(:locations) { [brixton_prison, wood_green_court] }
        let!(:court_move) do
          Move.create!(
            date: attributes[:date],
            time_due: attributes[:time_due],
            nomis_event_ids: [487_463_208],
            person: Person.find_by(nomis_prison_number: attributes[:person_nomis_prison_number]),
            from_location: wood_green_court,
            to_location: Location.find_by(nomis_agency_id: attributes[:to_location_nomis_agency_id])
          )
        end

        it 'cancels two moves' do
          expect { sweeper.call }.to change { Move.where(status: :cancelled).count }.by(2)
        end

        it 'cancels the move that matched the first location' do
          sweeper.call
          expect(outdated_move.reload.status).to eq 'cancelled'
        end

        it 'cancels the move that matched the second location' do
          sweeper.call
          expect(court_move.reload.status).to eq 'cancelled'
        end
      end

      context 'with a move with multiple nomis_event_ids' do
        let!(:multiple_nomis_ids_move) do
          Move.create!(
            date: attributes[:date],
            time_due: attributes[:time_due],
            nomis_event_ids: [attributes[:nomis_event_id], 123_456_789],
            person: prisoner_one,
            from_location: brixton_prison,
            to_location: wood_green_court
          )
        end

        it 'removes the outdated nomis_event_id' do
          sweeper.call
          expect(multiple_nomis_ids_move.reload.nomis_event_ids).to eq([attributes[:nomis_event_id]])
        end
      end
    end
  end
end
