# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'moves' }
  let(:eventable_id) { create(:move).id }

  it_behaves_like 'a generic event endpoint', 'move_accept',                                      'MoveAccept'
  it_behaves_like 'a generic event endpoint', 'move_approve',                                     'MoveApprove'
  it_behaves_like 'a generic event endpoint', 'move_cancel',                                      'MoveCancel'
  it_behaves_like 'a generic event endpoint', 'move_collection_by_escort',                        'MoveCollectionByEscort'
  it_behaves_like 'a generic event endpoint', 'move_complete',                                    'MoveComplete'
  it_behaves_like 'a generic event endpoint', 'move_cross_supplier_drop_off',                     'MoveCrossSupplierDropOff'
  it_behaves_like 'a generic event endpoint', 'move_cross_supplier_pick_up',                      'MoveCrossSupplierPickUp'
  it_behaves_like 'a generic event endpoint', 'move_lockout',                                     'MoveLockout'
  it_behaves_like 'a generic event endpoint', 'move_lodging_end',                                 'MoveLodgingEnd'
  it_behaves_like 'a generic event endpoint', 'move_lodging_start',                               'MoveLodgingStart'
  it_behaves_like 'a generic event endpoint', 'move_notify_premises_of_arrival_in_30_mins',       'MoveNotifyPremisesOfArrivalIn30Mins'
  it_behaves_like 'a generic event endpoint', 'move_notify_premises_of_eta',                      'MoveNotifyPremisesOfEta'
  it_behaves_like 'a generic event endpoint', 'move_notify_premises_of_expected_collection_time', 'MoveNotifyPremisesOfExpectedCollectionTime'
  it_behaves_like 'a generic event endpoint', 'move_operation_hmcts',                             'MoveOperationHmcts'
  it_behaves_like 'a generic event endpoint', 'move_operation_safeguard',                         'MoveOperationSafeguard'
  it_behaves_like 'a generic event endpoint', 'move_operation_tornado',                           'MoveOperationTornado'
  it_behaves_like 'a generic event endpoint', 'move_redirect',                                    'MoveRedirect'
  it_behaves_like 'a generic event endpoint', 'move_reject',                                      'MoveReject'
  it_behaves_like 'a generic event endpoint', 'move_start',                                       'MoveStart'
  it_behaves_like 'a generic event endpoint', 'person_move_assault',                              'PersonMoveAssault'
  it_behaves_like 'a generic event endpoint', 'person_move_booked_into_receiving_establishment',  'PersonMoveBookedIntoReceivingEstablishment'
  it_behaves_like 'a generic event endpoint', 'person_move_death_in_custody',                     'PersonMoveDeathInCustody'
  it_behaves_like 'a generic event endpoint', 'person_move_major_incident_other',                 'PersonMoveMajorIncidentOther'
  it_behaves_like 'a generic event endpoint', 'person_move_minor_incident_other',                 'PersonMoveMinorIncidentOther'
  it_behaves_like 'a generic event endpoint', 'person_move_person_escaped',                       'PersonMovePersonEscaped'
  it_behaves_like 'a generic event endpoint', 'person_move_person_escaped_kpi',                   'PersonMovePersonEscapedKpi'
  it_behaves_like 'a generic event endpoint', 'person_move_released_error',                       'PersonMoveReleasedError'
  it_behaves_like 'a generic event endpoint', 'person_move_road_traffic_accident',                'PersonMoveRoadTrafficAccident'
  it_behaves_like 'a generic event endpoint', 'person_move_serious_injury',                       'PersonMoveSeriousInjury'
  it_behaves_like 'a generic event endpoint', 'person_move_used_force',                           'PersonMoveUsedForce'
  it_behaves_like 'a generic event endpoint', 'person_move_vehicle_broke_down',                   'PersonMoveVehicleBrokeDown'
  it_behaves_like 'a generic event endpoint', 'person_move_vehicle_systems_failed',               'PersonMoveVehicleSystemsFailed'
end
