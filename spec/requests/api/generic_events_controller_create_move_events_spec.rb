# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'moves' }
  let(:eventable_id) { create(:move).id }

  it_behaves_like 'a generic event endpoint', 'move_accept', 'MoveAccept'
  it_behaves_like 'a generic event endpoint', 'move_approve', 'MoveApprove'
  it_behaves_like 'a generic event endpoint', 'move_cancel', 'MoveCancel'
  it_behaves_like 'a generic event endpoint', 'move_collection_by_escort', 'MoveCollectionByEscort'
  it_behaves_like 'a generic event endpoint', 'move_complete', 'MoveComplete'
  it_behaves_like 'a generic event endpoint', 'move_lockout', 'MoveLockout'
  it_behaves_like 'a generic event endpoint', 'move_lodging_end', 'MoveLodgingEnd'
  it_behaves_like 'a generic event endpoint', 'move_lodging_start', 'MoveLodgingStart'
  it_behaves_like 'a generic event endpoint', 'move_notify_premises_of_arrival_in_30_mins', 'MoveNotifyPremisesOfArrivalIn30Mins'
  it_behaves_like 'a generic event endpoint', 'move_notify_premises_of_eta', 'MoveNotifyPremisesOfEta'
  it_behaves_like 'a generic event endpoint', 'move_notify_premises_of_expected_collection_time', 'MoveNotifyPremisesOfExpectedCollectionTime'
  it_behaves_like 'a generic event endpoint', 'move_operation_hmcts', 'MoveOperationHmcts'
  it_behaves_like 'a generic event endpoint', 'move_operation_safeguard', 'MoveOperationSafeguard'
  it_behaves_like 'a generic event endpoint', 'move_operation_tornado', 'MoveOperationTornado'
  it_behaves_like 'a generic event endpoint', 'move_redirect', 'MoveRedirect'
  it_behaves_like 'a generic event endpoint', 'move_reject', 'MoveReject'
  it_behaves_like 'a generic event endpoint', 'move_start', 'MoveStart'
end
