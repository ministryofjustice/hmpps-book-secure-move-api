RSpec.describe GenericEvent::PersonMoveBookedIntoReceivingEstablishment do
  subject(:generic_event) { build(:event_person_move_booked_into_receiving_establishment) }

  it_behaves_like 'an event with details', :supplier_personnel_number
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event with eventable types', 'Person', 'Move'
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
  it_behaves_like 'an event with a location in the feed', :location_id
end
