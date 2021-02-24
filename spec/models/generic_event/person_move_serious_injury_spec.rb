require 'rails_helper'

RSpec.describe GenericEvent::PersonMoveSeriousInjury do
  subject(:generic_event) { build(:event_person_move_serious_injury) }

  it_behaves_like 'an event about an incident'
end
