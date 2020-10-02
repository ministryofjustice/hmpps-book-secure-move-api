RSpec.describe GenericEvent::MoveCollectionByEscort do
  subject(:generic_event) { build(:event_per_court_excessive_delay_not_due_to_supplier) }

  let(:subtypes) do
    %w[
      making_prisoner_available_for_loading
      access_to_or_from_location_when_collecting_dropping_off_prisoner
    ]
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_inclusion_of(:subtype).in_array(subtypes) }
end
