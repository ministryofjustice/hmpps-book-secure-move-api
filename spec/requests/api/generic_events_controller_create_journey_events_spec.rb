# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'journeys' }
  let(:eventable_id) { create(:journey).id }

  it_behaves_like 'a generic event endpoint', 'journey_admit_through_outer_gate', 'JourneyAdmitThroughOuterGate'
  it_behaves_like 'a generic event endpoint', 'journey_arrive_at_outer_gate', 'JourneyArriveAtOuterGate'
  it_behaves_like 'a generic event endpoint', 'journey_cancel', 'JourneyCancel'
  it_behaves_like 'a generic event endpoint', 'journey_change_vehicle', 'JourneyChangeVehicle'
  it_behaves_like 'a generic event endpoint', 'journey_complete', 'JourneyComplete'
  it_behaves_like 'a generic event endpoint', 'journey_create', 'JourneyCreate'
  it_behaves_like 'a generic event endpoint', 'journey_exit_through_outer_gate', 'JourneyExitThroughOuterGate'
  it_behaves_like 'a generic event endpoint', 'journey_handover_to_destination', 'JourneyHandoverToDestination'
  it_behaves_like 'a generic event endpoint', 'journey_lockout', 'JourneyLockout'
  it_behaves_like 'a generic event endpoint', 'journey_lodging', 'JourneyLodging'
  it_behaves_like 'a generic event endpoint', 'journey_person_boards_vehicle', 'JourneyPersonBoardsVehicle'
  it_behaves_like 'a generic event endpoint', 'journey_person_leave_vehicle', 'JourneyPersonLeaveVehicle'
  it_behaves_like 'a generic event endpoint', 'journey_ready_to_exit', 'JourneyReadyToExit'
  it_behaves_like 'a generic event endpoint', 'journey_reject', 'JourneyReject'
  it_behaves_like 'a generic event endpoint', 'journey_start', 'JourneyStart'
  it_behaves_like 'a generic event endpoint', 'journey_uncancel', 'JourneyUncancel'
  it_behaves_like 'a generic event endpoint', 'journey_uncomplete', 'JourneyUncomplete'
  it_behaves_like 'a generic event endpoint', 'journey_update', 'JourneyUpdate'
end
