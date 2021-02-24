require 'rails_helper'

RSpec.describe GenericEvent::PersonMoveAssault do
  subject(:generic_event) { build(:event_person_move_assault) }

  it_behaves_like 'an event about an incident'
end
