RSpec.describe GenericEvent::PerCourtAllDocumentationProvidedToSupplier do
  subject(:generic_event) { build(:event_per_court_all_documentation_provided_to_supplier) }

  let(:subtypes) do
    %w[
      extradition_order
      warrant
      placement_confirmation
    ]
  end

  it_behaves_like 'an event with details', :subtype
  it_behaves_like 'an event with relationships', court_location_id: :locations
  it_behaves_like 'an event requiring a location', :court_location_id
  it_behaves_like 'an event with a location in the feed', :court_location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_inclusion_of(:subtype).in_array(subtypes) }
end
