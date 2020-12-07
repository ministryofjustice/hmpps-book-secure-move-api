# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:eventable_type) { 'person_escort_records' }
  let(:eventable_id) { create(:person_escort_record).id }

  it_behaves_like 'a generic event endpoint', 'PerCourtAllDocumentationProvidedToSupplier'
  it_behaves_like 'a generic event endpoint', 'PerCourtAssignCellInCustody'
  it_behaves_like 'a generic event endpoint', 'PerCourtCellShareRiskAssessment'
  it_behaves_like 'a generic event endpoint', 'PerCourtExcessiveDelayNotDueToSupplier'
  it_behaves_like 'a generic event endpoint', 'PerCourtHearing'
  it_behaves_like 'a generic event endpoint', 'PerCourtReadyInCustody'
  it_behaves_like 'a generic event endpoint', 'PerCourtReturnToCustodyAreaFromDock'
  it_behaves_like 'a generic event endpoint', 'PerCourtPreReleaseChecksCompleted'
  it_behaves_like 'a generic event endpoint', 'PerCourtRelease'
  it_behaves_like 'a generic event endpoint', 'PerCourtReleaseOnBail'
  it_behaves_like 'a generic event endpoint', 'PerCourtReturnToCustodyAreaFromVisitorArea'
  it_behaves_like 'a generic event endpoint', 'PerCourtTakeFromCustodyToDock'
  it_behaves_like 'a generic event endpoint', 'PerCourtTakeToSeeVisitors'
  it_behaves_like 'a generic event endpoint', 'PerCourtTask'
  it_behaves_like 'a generic event endpoint', 'PerGeneric'
  it_behaves_like 'a generic event endpoint', 'PerMedicalAid'
  it_behaves_like 'a generic event endpoint', 'PerPrisonerWelfare'
end
