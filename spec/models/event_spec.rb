require 'rails_helper'

RSpec.describe Event, type: :model do
  it { is_expected.to belong_to(:move) }
  it { is_expected.to validate_presence_of(:move) }
  it { is_expected.to validate_presence_of(:event_name) }
  it { is_expected.to validate_presence_of(:client_timestamp) }
  it { expect(described_class).to respond_to(:default_order) }
  it 'validates event_name' do
    expect(described_class.new).to validate_inclusion_of(:event_name).in_array(%w(
      move_created move_updated move_completed move_cancelled move_redirected move_lockout
      journey_created journey_updated journey_completed journey_uncompleted journey_cancelled journey_uncancelled
    ))
  end
end
