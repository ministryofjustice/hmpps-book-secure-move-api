require 'rails_helper'

RSpec.describe Lodging do
  subject(:lodging) { build(:lodging, start_date:, end_date:) }

  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-02' }

  it { is_expected.to belong_to(:move) }
  it { is_expected.to belong_to(:location) }

  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:end_date) }
  it { is_expected.to validate_presence_of(:move) }
  it { is_expected.to validate_presence_of(:location) }

  context 'when the start_date format is not an iso8601 date' do
    let(:start_date) { '2023/01/01' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date format is not an iso8601 date' do
    let(:end_date) { '2023/01/02' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date is before the start_date' do
    let(:end_date) { '2022-12-31' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date is same as the start_date' do
    let(:end_date) { '2023-01-01' }

    it { is_expected.to be_invalid }
  end

  context 'when it is not unique' do
    subject(:lodging) { build(:lodging, start_date:, end_date:, move: existing_lodging.move) }

    let(:existing_lodging) { create(:lodging, start_date:, end_date:) }

    it { is_expected.to be_invalid }
  end

  it 'has state machine' do
    expect(described_class.state_machine_class).to eq(LodgingStateMachine)
  end
end
