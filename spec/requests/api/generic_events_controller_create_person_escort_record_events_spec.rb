# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'person_escort_records' }
  let(:eventable_id) { create(:person_escort_record).id }

  it_behaves_like 'a generic event endpoint', 'per_court_all_documentation_provided_to_supplier', 'PerCourtAllDocumentationProvidedToSupplier'
  it_behaves_like 'a generic event endpoint', 'per_court_assign_cell_in_custody', 'PerCourtAssignCellInCustody'
  it_behaves_like 'a generic event endpoint', 'per_court_cell_share_risk_assessment', 'PerCourtCellShareRiskAssessment'
  it_behaves_like 'a generic event endpoint', 'per_court_excessive_delay_not_due_to_supplier', 'PerCourtExcessiveDelayNotDueToSupplier'
  it_behaves_like 'a generic event endpoint', 'per_court_ready_in_custody', 'PerCourtReadyInCustody'
  it_behaves_like 'a generic event endpoint', 'per_court_return_to_custody_area_from_dock', 'PerCourtReturnToCustodyAreaFromDock'
end
