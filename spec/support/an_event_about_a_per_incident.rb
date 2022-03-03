RSpec.shared_examples 'an event about a PER incident' do
  it_behaves_like 'an event with details', :supplier_personnel_number, :police_personnel_number
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event with eventable types', 'PersonEscortRecord'
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_presence_of(:supplier_personnel_number) }
end
