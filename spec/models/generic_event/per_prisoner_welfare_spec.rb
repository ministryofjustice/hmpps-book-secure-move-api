require 'rails_helper'

RSpec.describe GenericEvent::PerPrisonerWelfare do
  subject(:generic_event) { build(:event_per_prisoner_welfare) }

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
  let(:outcomes) do
    %w[accepted refused]
  end

  it_behaves_like 'an event with details', :given_at, :outcome, :subtype, :vehicle_reg, :supplier_personnel_number
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_presence_of(:given_at) }

  it { is_expected.to validate_inclusion_of(:outcome).in_array(outcomes) }
  it { is_expected.to validate_inclusion_of(:subtype).in_array(subtypes) }
  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  context 'when the given_at date time format is not an iso8601 date' do
    before do
      generic_event.given_at = given_at
    end

    let(:given_at) { '2019/01/01T18:00:00' }

    it { is_expected.not_to be_valid }
  end
end
