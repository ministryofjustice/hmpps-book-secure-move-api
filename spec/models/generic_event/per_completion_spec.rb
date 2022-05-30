require 'rails_helper'

RSpec.describe GenericEvent::PerCompletion do
  subject(:generic_event) { build(:event_per_confirmation) }

  it_behaves_like 'an event with details', :completed_at, :responded_by

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_presence_of(:confirmed_at) }
end
