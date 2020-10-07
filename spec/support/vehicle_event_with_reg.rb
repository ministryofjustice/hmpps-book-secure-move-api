RSpec.shared_examples 'an event that specifies a vehicle registration' do
  it { is_expected.to validate_presence_of(:vehicle_reg) }
end
