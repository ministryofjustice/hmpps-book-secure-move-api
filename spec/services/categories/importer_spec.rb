# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Categories::Importer do
  subject(:importer) { described_class.new(input_data) }

  let!(:location1) { create :location, nomis_agency_id: 'FOO' }
  let(:input_data) do
    {
      'A': {
        title: 'Category A',
        move_supported: false,
        locations: nil,
      },
      'B': {
        title: 'Category B',
        move_supported: true,
        locations: %w[FOO BAR],
      },
      'C': {
        title: 'Category C',
        move_supported: true,
        locations: %w[BAZ BUZZ],
      },
    }
  end
  let(:category_a) { Category.find_by(key: 'A') }
  let(:category_b) { Category.find_by(key: 'B') }
  let(:category_c) { Category.find_by(key: 'C') }

  before do
    create :location, nomis_agency_id: 'BAR'
    create :location, nomis_agency_id: 'BAZ'
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Category, :count).by(3)
    end

    it 'populates correct title' do
      importer.call

      expect(category_a.title).to eq 'Category A'
    end

    it 'populates correct move_supported flag' do
      importer.call

      expect(category_a).not_to be_move_supported
    end

    it 'links to correct locations' do
      importer.call

      expect(category_b.locations.map(&:nomis_agency_id)).to match_array %w[FOO BAR]
    end

    it 'does not link to missing locations' do
      importer.call

      expect(category_c.locations.map(&:nomis_agency_id)).to match_array %w[BAZ]
    end

    it 'does not link to nil locations' do
      importer.call

      expect(category_a.locations).to be_empty
    end
  end

  context 'with one existing record' do
    before do
      create(:category, key: 'A', title: 'Category A')
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(Category, :count).by(2)
    end
  end

  context 'with one existing record with the wrong name' do
    let!(:existing) { create(:category, :not_supported, key: 'C', title: 'Wrong', locations: [location1]) }

    it 'updates the title of the existing record' do
      importer.call
      expect(existing.reload.title).to eq 'Category C'
    end

    it 'updates the move_supported flag of the existing record' do
      importer.call
      expect(existing.reload).to be_move_supported
    end

    it 'updates links to correct locations' do
      importer.call
      expect(existing.reload.locations.map(&:nomis_agency_id)).to match_array %w[BAZ]
    end
  end
end
