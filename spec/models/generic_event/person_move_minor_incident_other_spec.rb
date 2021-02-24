require 'rails_helper'

RSpec.describe GenericEvent::PersonMoveMinorIncidentOther do
  subject(:generic_event) { build(:event_person_move_minor_incident_other) }

  it_behaves_like 'an event about an incident'
end
