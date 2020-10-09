RSpec.describe GenericEvent::PerPrisonerWelfare do
  subject(:generic_event) { build(:event_per_prisoner_welfare) }

  let(:outcomes) do
    %w[accepted refused]
  end

  let(:subtypes) do
    %w[
      comfort_break
      food
      beverage
      additional_clothing
      relevant_information_given
      miscellaneous_welfare
    ]
  end

  it { is_expected.to validate_presence_of(:given_at) }

  it { is_expected.to validate_inclusion_of(:outcome).in_array(outcomes) }
  it { is_expected.to validate_inclusion_of(:subtype).in_array(subtypes) }
  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
end
