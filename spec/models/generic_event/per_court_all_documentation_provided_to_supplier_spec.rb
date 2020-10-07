RSpec.describe GenericEvent::PerCourtAllDocumentationProvidedToSupplier do
  subject(:generic_event) { build(:event_per_court_all_documentation_provided_to_supplier) }

  let(:subtypes) do
    %w[
      extradition_order
      warrant
      placement_confirmation
    ]
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_inclusion_of(:subtype).in_array(subtypes) }
  it { is_expected.to validate_presence_of(:court_location_id) }
end
