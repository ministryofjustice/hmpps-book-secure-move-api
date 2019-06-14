# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }
  it { is_expected.to belong_to(:person) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }
  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:time_due) }
  it { is_expected.to validate_presence_of(:move_type) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }

  context 'without automatic reference generation' do
    # rubocop:disable RSpec/AnyInstance
    before { allow_any_instance_of(described_class).to receive(:set_reference).and_return(nil) }
    # rubocop:enable RSpec/AnyInstance

    it { is_expected.to validate_presence_of(:reference) }
  end

  describe '#reference' do
    subject(:move) { described_class.new }

    it 'generates a new unique reference before validation' do
      move.valid?
      expect(move.reference).to be_present
    end

    it 'does not overwrite an existing reference on validation' do
      move = described_class.new(reference: '12345678')
      expect(move.reference).to eq '12345678'
    end
  end
end
