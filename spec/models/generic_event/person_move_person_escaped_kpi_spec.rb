require 'rails_helper'

RSpec.describe GenericEvent::PersonMovePersonEscapedKpi do
  subject(:generic_event) { build(:event_person_move_person_escaped_kpi) }

  it_behaves_like 'an event about an incident'
end
