# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'journeys' }
  let(:eventable_id) { create(:journey).id }

  it_behaves_like 'a generic event endpoint', 'JourneyAdmitThroughOuterGate'
  it_behaves_like 'a generic event endpoint', 'JourneyAdmitToReception'
  it_behaves_like 'a generic event endpoint', 'JourneyArriveAtOuterGate'
  it_behaves_like 'a generic event endpoint', 'JourneyCancel'
  it_behaves_like 'a generic event endpoint', 'JourneyChangeVehicle'
  it_behaves_like 'a generic event endpoint', 'JourneyComplete'
  it_behaves_like 'a generic event endpoint', 'JourneyCreate'
  it_behaves_like 'a generic event endpoint', 'JourneyExitThroughOuterGate'
  it_behaves_like 'a generic event endpoint', 'JourneyHandoverToDestination'
  it_behaves_like 'a generic event endpoint', 'JourneyHandoverToSupplier'
  it_behaves_like 'a generic event endpoint', 'JourneyLockout'
  it_behaves_like 'a generic event endpoint', 'JourneyLodging'
  it_behaves_like 'a generic event endpoint', 'JourneyPersonBoardsVehicle'
  it_behaves_like 'a generic event endpoint', 'JourneyPersonLeaveVehicle'
  it_behaves_like 'a generic event endpoint', 'JourneyReadyToExit'
  it_behaves_like 'a generic event endpoint', 'JourneyReject'
  it_behaves_like 'a generic event endpoint', 'JourneyStart'
  it_behaves_like 'a generic event endpoint', 'JourneyUncancel'
  it_behaves_like 'a generic event endpoint', 'JourneyUncomplete'
  it_behaves_like 'a generic event endpoint', 'JourneyUpdate'
end
