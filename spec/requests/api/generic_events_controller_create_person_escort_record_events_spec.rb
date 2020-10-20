# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'person_escort_records' }
  let(:eventable_id) { create(:person_escort_record).id }

  it_behaves_like 'a generic event endpoint', 'per_court_all_documentation_provided_to_supplier', 'PerCourtAllDocumentationProvidedToSupplier'
  it_behaves_like 'a generic event endpoint', 'per_court_assign_cell_in_custody', 'PerCourtAssignCellInCustody'
  it_behaves_like 'a generic event endpoint', 'per_court_cell_share_risk_assessment', 'PerCourtCellShareRiskAssessment'
  it_behaves_like 'a generic event endpoint', 'per_court_excessive_delay_not_due_to_supplier', 'PerCourtExcessiveDelayNotDueToSupplier'
  it_behaves_like 'a generic event endpoint', 'per_court_hearing', 'PerCourtHearing'
  it_behaves_like 'a generic event endpoint', 'per_court_ready_in_custody', 'PerCourtReadyInCustody'
  it_behaves_like 'a generic event endpoint', 'per_court_return_to_custody_area_from_dock', 'PerCourtReturnToCustodyAreaFromDock'
  it_behaves_like 'a generic event endpoint', 'per_court_pre_release_checks_completed', 'PerCourtPreReleaseChecksCompleted'
  it_behaves_like 'a generic event endpoint', 'per_court_release', 'PerCourtRelease'
  it_behaves_like 'a generic event endpoint', 'per_court_release_on_bail', 'PerCourtReleaseOnBail'
  it_behaves_like 'a generic event endpoint', 'per_court_return_to_custody_area_from_visitor_area', 'PerCourtReturnToCustodyAreaFromVisitorArea'
  it_behaves_like 'a generic event endpoint', 'per_court_take_from_custody_to_dock', 'PerCourtTakeFromCustodyToDock'
  it_behaves_like 'a generic event endpoint', 'per_court_take_to_see_visitors', 'PerCourtTakeToSeeVisitors'
  it_behaves_like 'a generic event endpoint', 'per_court_task', 'PerCourtTask'
  it_behaves_like 'a generic event endpoint', 'per_generic', 'PerGeneric'
  it_behaves_like 'a generic event endpoint', 'per_medical_aid', 'PerMedicalAid'
  it_behaves_like 'a generic event endpoint', 'per_prisoner_welfare', 'PerPrisonerWelfare'
end
