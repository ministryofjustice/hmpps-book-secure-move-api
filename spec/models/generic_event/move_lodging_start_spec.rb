RSpec.describe GenericEvent::MoveLodgingStart do
  subject(:generic_event) { build(:event_move_lodging_start) }

  let(:reasons) do
    %w[
      overnight_lodging
      lockout
      operation_hmcts
      court_cells
      operation_tornado
      operation_safeguard
      other
    ]
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_inclusion_of(:reason).in_array(reasons) }
  it { is_expected.to validate_presence_of(:location_id) }

  it 'is valid when reason is nil' do
    generic_event.reason = nil
    expect(generic_event).to be_valid
  end
end
