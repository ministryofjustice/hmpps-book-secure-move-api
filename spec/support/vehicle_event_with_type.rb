RSpec.shared_examples 'an event that specifies a vehicle type' do
  let(:vehicle_types) do
    %w[
      c4
      pro_cab
      mpv
      2_cell
      3_cell
      6_cell
      12_cell
    ]
  end

  it { is_expected.to validate_inclusion_of(:vehicle_type).in_array(vehicle_types) }
end
