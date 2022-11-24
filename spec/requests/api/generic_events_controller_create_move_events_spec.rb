# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'moves' }
  let(:eventable_id) { create(:move).id }

  it_behaves_like 'a generic event endpoint', 'MoveAccept'
  it_behaves_like 'a generic event endpoint', 'MoveApprove'
  it_behaves_like 'a generic event endpoint', 'MoveCancel'
  it_behaves_like 'a generic event endpoint', 'MoveCollectionByEscort'
  it_behaves_like 'a generic event endpoint', 'MoveComplete'
  it_behaves_like 'a generic event endpoint', 'MoveCrossSupplierDropOff'
  it_behaves_like 'a generic event endpoint', 'MoveCrossSupplierPickUp'
  it_behaves_like 'a generic event endpoint', 'MoveDateChanged'
  it_behaves_like 'a generic event endpoint', 'MoveLockout'
  it_behaves_like 'a generic event endpoint', 'MoveLodgingEnd'
  it_behaves_like 'a generic event endpoint', 'MoveLodgingStart'
  it_behaves_like 'a generic event endpoint', 'MoveNotifyPremisesOfArrivalIn30Mins'
  it_behaves_like 'a generic event endpoint', 'MoveNotifyPremisesOfDropOffEta'
  it_behaves_like 'a generic event endpoint', 'MoveNotifyPremisesOfPickupEta'
  it_behaves_like 'a generic event endpoint', 'MoveNotifyPremisesOfExpectedCollectionTime'
  it_behaves_like 'a generic event endpoint', 'MoveOperationHmcts'
  it_behaves_like 'a generic event endpoint', 'MoveOperationSafeguard'
  it_behaves_like 'a generic event endpoint', 'MoveOperationTornado'
  it_behaves_like 'a generic event endpoint', 'MoveRedirect'
  it_behaves_like 'a generic event endpoint', 'MoveReject'
  it_behaves_like 'a generic event endpoint', 'MoveStart'
  it_behaves_like 'a generic event endpoint', 'PersonMoveAssault'
  it_behaves_like 'a generic event endpoint', 'PersonMoveBookedIntoReceivingEstablishment'
  it_behaves_like 'a generic event endpoint', 'PersonMoveDeathInCustody'
  it_behaves_like 'a generic event endpoint', 'PersonMoveMajorIncidentOther'
  it_behaves_like 'a generic event endpoint', 'PersonMoveMinorIncidentOther'
  it_behaves_like 'a generic event endpoint', 'PersonMovePersonEscaped'
  it_behaves_like 'a generic event endpoint', 'PersonMovePersonEscapedKpi'
  it_behaves_like 'a generic event endpoint', 'PersonMoveReleasedError'
  it_behaves_like 'a generic event endpoint', 'PersonMoveRoadTrafficAccident'
  it_behaves_like 'a generic event endpoint', 'PersonMoveSeriousInjury'
  it_behaves_like 'a generic event endpoint', 'PersonMoveUsedForce'
  it_behaves_like 'a generic event endpoint', 'PersonMoveVehicleBrokeDown'
  it_behaves_like 'a generic event endpoint', 'PersonMoveVehicleSystemsFailed'

  describe 'remapping of MoveNotifyPremisesOfEta to MoveNotifyPremisesOfDropOffEta' do
    let(:headers) do
      {
        'CONTENT_TYPE': ApiController::CONTENT_TYPE,
        'Accept': 'application/vnd.api+json; version=2',
        'Authorization' => 'Bearer spoofed-token',
      }
    end
    let(:data) do
      {
        type: 'events',
        attributes: {
          event_type: 'MoveNotifyPremisesOfEta',
          occurred_at: '2019-06-16T10:20:30+01:00',
          recorded_at: '2019-06-16T10:20:30+01:00',
          details: {
            expected_at: '2019-06-16T10:20:30+01:00',
          },
        },
        relationships: {
          eventable: { data: { type: eventable_type, id: eventable_id } },
        },
      }
    end

    it 'correctly remaps the old event' do
      expect {
        post '/api/events',
             headers: headers,
             params: { data: data },
             as: :json
      }.to change(GenericEvent::MoveNotifyPremisesOfDropOffEta, :count).by(1)
    end
  end

  context 'when a move has been approved' do
    subject(:move) { create(:move, :proposed) }

    let(:original_date) { Time.zone.today }
    let(:headers) do
      {
        'CONTENT_TYPE': ApiController::CONTENT_TYPE,
        'Accept': 'application/vnd.api+json; version=2',
        'Authorization' => 'Bearer spoofed-token',
      }
    end

    before do
      post '/api/events',
           headers: headers,
           params: { data: {
             type: 'events',
             attributes: {
               event_type: 'MoveApprove',
               occurred_at: '2019-06-16T10:20:30+01:00',
               recorded_at: '2019-06-16T10:20:30+01:00',
               details: {
                 date: original_date.to_s,
               },
             },
             relationships: {
               eventable: { data: { type: 'moves', id: move.id } },
             },
           } },
           as: :json
    end

    it 'is in the requested state' do
      move.reload
      expect(move.status).to eq('requested')
    end

    context "when the move's date has been changed" do
      before do
        move.date = original_date + 1
        move.save!
      end

      context 'when a new event is added' do
        before do
          post '/api/events',
               headers: headers,
               params: { data: {
                 type: 'events',
                 attributes: {
                   event_type: 'MoveCollectionByEscort',
                   occurred_at: '2019-06-16T10:20:30+01:00',
                   recorded_at: '2019-06-16T10:20:30+01:00',
                   details: {
                     vehicle_type: '2_cell',
                   },
                 },
                 relationships: {
                   eventable: { data: { type: 'moves', id: move.id } },
                 },
               } },
               as: :json
        end

        it 'does not revert to the original date' do
          move.reload
          expect(move.generic_events.count).to eq(2)
          expect(move.date).to eq(original_date + 1)
        end
      end
    end
  end
end
