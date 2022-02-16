require 'rails_helper'

RSpec.describe GenericEvent::PerPropertyChange do
  subject(:generic_event) { build(:event_per_property_change) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end
