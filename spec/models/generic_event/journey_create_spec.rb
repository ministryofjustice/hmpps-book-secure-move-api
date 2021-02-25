require 'rails_helper'

RSpec.describe GenericEvent::JourneyCreate do
  subject(:generic_event) { build(:event_journey_cancel) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end
