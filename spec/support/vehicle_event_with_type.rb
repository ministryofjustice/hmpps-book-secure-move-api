RSpec.shared_examples 'an event that specifies a vehicle type' do
  let(:vehicle_types) do
    %w[
      cellular
      mpv
      other
    ]
  end

  it { is_expected.to validate_inclusion_of(:vehicle_type).in_array(vehicle_types) }
end
