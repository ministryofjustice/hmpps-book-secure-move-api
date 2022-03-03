require 'rails_helper'

RSpec.describe GenericEvent::PerSelfHarm do
  subject(:generic_event) { build(:event_per_self_harm) }

  it_behaves_like 'an event about a PER incident'
end
