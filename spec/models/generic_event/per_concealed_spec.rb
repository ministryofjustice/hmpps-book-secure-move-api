require 'rails_helper'

RSpec.describe GenericEvent::PerConcealed do
  subject(:generic_event) { build(:event_per_concealed) }

  it_behaves_like 'an event about a PER incident'
end
