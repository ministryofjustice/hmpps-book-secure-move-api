require 'rails_helper'

RSpec.describe GenericEvent::PerUpdated do
  subject(:generic_event) { build(:event_per_updated) }

  it_behaves_like 'an event with details', :section, :responded_by

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end
