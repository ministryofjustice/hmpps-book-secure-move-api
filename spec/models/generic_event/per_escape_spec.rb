require 'rails_helper'

RSpec.describe GenericEvent::PerEscape do
  subject(:generic_event) { build(:event_per_escape) }

  it_behaves_like 'an event about a PER incident'
end
