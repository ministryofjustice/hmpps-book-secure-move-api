RSpec.describe GenericEvent::PerCourtExcessiveDelayNotDueToSupplier do
  subject(:generic_event) { build(:event_per_court_excessive_delay_not_due_to_supplier) }

  let(:subtypes) do
    %w[
      making_prisoner_available_for_loading
      access_to_or_from_location_when_collecting_dropping_off_prisoner
    ]
  end

  it_behaves_like 'an event with details', :subtype, :vehicle_reg, :ended_at, :authorised_by, :authorised_at
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_inclusion_of(:subtype).in_array(subtypes) }
  it { is_expected.to validate_presence_of(:ended_at) }

  context 'with incorrect non iso8601 ended_at' do
    before do
      generic_event.details[:ended_at] = '2019/01/01 20:00'
    end

    it { is_expected.not_to be_valid }
  end
end
