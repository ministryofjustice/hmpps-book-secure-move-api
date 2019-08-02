# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethnicities::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [
      {
        key: 'a1',
        nomis_code: 'A1',
        title: 'Asian/Asian British: Indian'
      },
      {
        key: 'w9',
        nomis_code: 'W9',
        title: 'White: Any other background'
      },
      {
        key: 'merge',
        nomis_code: 'MERGE',
        title: 'Needs to be confirmed following Merge'
      }
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Ethnicity, :count).by(3)
    end

    it 'creates a1' do
      importer.call
      expect(Ethnicity.find_by(key: 'a1', nomis_code: 'A1', title: 'Asian/Asian British: Indian')).to be_present
    end

    it 'creates w9' do
      importer.call
      expect(Ethnicity.find_by(key: 'w9', nomis_code: 'W9', title: 'White: Any other background')).to be_present
    end

    it 'creates merge' do
      importer.call
      expect(
        Ethnicity.find_by(key: 'merge', nomis_code: 'MERGE', title: 'Needs to be confirmed following Merge')
      ).to be_present
    end
  end

  context 'with one existing record' do
    before do
      Ethnicity.create!(
        key: 'w9',
        nomis_code: 'W9',
        title: 'White: Any other background'
      )
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(Ethnicity, :count).by(2)
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:w9) do
      Ethnicity.create!(
        key: 'w9',
        nomis_code: 'W9',
        title: 'Other white'
      )
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(w9.reload.title).to eq 'White: Any other background'
    end
  end

  context 'with one existing record that should be hidden' do
    let!(:merge) do
      Ethnicity.create!(
        key: 'merge',
        nomis_code: 'MERGE',
        title: 'Needs to be confirmed following Merge',
        disabled_at: nil
      )
    end

    it 'sets the `#disabled_at` of the "hidden" record' do
      importer.call
      expect(merge.reload.disabled_at).not_to be_nil
    end
  end
end
