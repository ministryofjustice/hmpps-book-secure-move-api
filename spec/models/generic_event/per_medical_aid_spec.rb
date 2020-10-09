RSpec.describe GenericEvent::PerMedicalAid do
  subject(:generic_event) { build(:event_per_medical_aid) }

  it { is_expected.to validate_presence_of(:advised_at) }
  it { is_expected.to validate_presence_of(:advised_by) }
  it { is_expected.to validate_presence_of(:treated_at) }
  it { is_expected.to validate_presence_of(:treated_by) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
end
