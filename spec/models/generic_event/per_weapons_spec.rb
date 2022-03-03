require 'rails_helper'

RSpec.describe GenericEvent::PerWeapons do
  subject(:generic_event) { build(:event_per_weapons) }

  it_behaves_like 'an event about a PER incident'
end
