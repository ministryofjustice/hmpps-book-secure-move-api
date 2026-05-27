require 'rails_helper'

RSpec.describe GenericEvent::PerHistoricSelfHarm do
  subject(:generic_event) { build(:event_per_historic_self_harm) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end
