require 'rails_helper'

RSpec.describe GenericEvent::PerViolentDangerous do
  subject(:generic_event) { build(:event_per_violent_dangerous) }

  it_behaves_like 'an event about a PER incident'
end
