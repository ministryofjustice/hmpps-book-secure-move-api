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
end
