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
  it_behaves_like 'a generic event endpoint', 'MoveNotifyPremisesOfEta'
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
end
