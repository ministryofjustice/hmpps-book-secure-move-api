require 'rails_helper'

RSpec.describe Event, type: :model do
  it { is_expected.to belong_to(:eventable) }
  it { is_expected.to validate_presence_of(:eventable) }
  it { is_expected.to validate_presence_of(:event_name) }
  it { is_expected.to validate_presence_of(:client_timestamp) }
  it { expect(described_class).to respond_to(:default_order) }
  it 'validates event_name' do
    expect(described_class.new).to validate_inclusion_of(:event_name).in_array(%w(
    create update cancel uncancel complete uncomplete redirect lockout
    ))
  end
end
