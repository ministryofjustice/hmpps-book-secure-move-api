require 'rails_helper'

RSpec.describe GenericEvent::PersonMoveUsedForce do
  subject(:generic_event) { build(:event_person_move_used_force) }

  it_behaves_like 'an event about an incident'
end
