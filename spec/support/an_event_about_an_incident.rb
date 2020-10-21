RSpec.shared_examples 'an event about an incident' do
  it_behaves_like 'an event with details', :supplier_personnel_numbers, :vehicle_reg, :reported_at
  it_behaves_like 'an event with relationships', :location_id
  it_behaves_like 'an event with eventable types', 'Person', 'Move'
  it_behaves_like 'an event requiring a location', :location_id

  it { is_expected.to validate_presence_of(:supplier_personnel_numbers) }

  context 'when reported_at is not a valid iso8601 date' do
    before do
      generic_event.reported_at = '2019/01/01'
    end

    it { is_expected.not_to be_valid }
  end
end