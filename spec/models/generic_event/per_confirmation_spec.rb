RSpec.describe GenericEvent::PerConfirmation do
  subject(:generic_event) { build(:event_per_confirmation) }

  it_behaves_like 'an event with details', :confirmed_at

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_presence_of(:confirmed_at) }
end
