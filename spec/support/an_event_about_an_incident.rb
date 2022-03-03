RSpec.shared_examples 'an event about an incident' do
  it_behaves_like 'an event with details', :supplier_personnel_numbers, :police_personnel_numbers, :vehicle_reg, :reported_at, :fault_classification
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event with eventable types', 'Person', 'Move'
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  let(:fault_classifications) do
    %w[
      was_not_supplier
      supplier
      investigation
    ]
  end

  it { is_expected.to validate_presence_of(:supplier_personnel_numbers) }
  it { is_expected.to validate_inclusion_of(:fault_classification).in_array(fault_classifications) }
  it { is_expected.to validate_presence_of(:fault_classification) }

  context 'when reported_at is not a valid iso8601 date' do
    before do
      generic_event.reported_at = '2019/01/01'
    end

    it { is_expected.not_to be_valid }
  end
end
