RSpec.describe GenericEvent::PerHandover do
  subject(:generic_event) { build(:event_per_handover) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end
