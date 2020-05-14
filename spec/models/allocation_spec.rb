# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocation do
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }

  it { is_expected.to have_many(:moves) }
  it { is_expected.to have_many(:events) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }

  it { is_expected.to allow_value(nil).for(:prisoner_category) }
  it { is_expected.to define_enum_for(:prisoner_category).backed_by_column_of_type(:string) }
  it { is_expected.to allow_value(nil).for(:sentence_length) }
  it { is_expected.to define_enum_for(:sentence_length).backed_by_column_of_type(:string) }

  it { is_expected.to allow_value(nil).for(:status) }
  it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:string) }

  it { is_expected.to validate_presence_of(:moves_count) }
  it { is_expected.to validate_numericality_of(:moves_count) }
  it { is_expected.to validate_presence_of(:date) }

  context 'with versioning' do
    let(:allocation) { create(:allocation) }

    it 'has a version record for the create' do
      expect(allocation.versions.map(&:event)).to eq(%w[create])
    end
  end

  describe 'cancellation_reason' do
    context 'when the allocation is not cancelled' do
      let(:allocation) { build(:allocation, status: nil) }

      it { expect(allocation).to validate_absence_of(:cancellation_reason) }
    end

    context 'when the allocation is cancelled' do
      let(:allocation) { build(:allocation, status: 'cancelled') }

      it {
        expect(allocation).to validate_inclusion_of(:cancellation_reason)
          .in_array(%w[
            made_in_error
            supplier_declined_to_move
            other
            lack_of_space_at_receiving_establishment
            sending_establishment_failed_to_fill_allocation
          ])
      }
    end
  end
end
