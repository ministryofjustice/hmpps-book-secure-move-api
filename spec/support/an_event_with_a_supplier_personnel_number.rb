RSpec.shared_examples 'an event with a supplier personnel number' do
  it { is_expected.to validate_presence_of(:supplier_personnel_number) }
end
