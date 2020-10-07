RSpec.describe GenericEvent::PerCourtCellShareRiskAssessment do
  subject(:generic_event) { build(:event_per_court_cell_share_risk_assessment) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
end
