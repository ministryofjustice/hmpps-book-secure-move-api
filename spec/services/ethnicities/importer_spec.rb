# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethnicities::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [
      {
        key: 'A1',
        title: 'Asian/Asian British: Indian'
      },
      {
        key: 'W9',
        title: 'White: Any other background'
      }
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Ethnicity, :count).by(2)
    end

    it 'creates a1' do
      importer.call
      expect(Ethnicity.find_by(key: 'A1', title: 'Asian/Asian British: Indian')).to be_present
    end

    it 'creates w9' do
      importer.call
      expect(Ethnicity.find_by(key: 'W9', title: 'White: Any other background')).to be_present
    end
  end

  context 'with one existing record' do
    before do
      Ethnicity.create!(
        key: 'W9',
        title: 'White: Any other background'
      )
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(Ethnicity, :count).by(1)
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:w9) do
      Ethnicity.create!(
        key: 'W9',
        title: 'Other white'
      )
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(w9.reload.title).to eq 'White: Any other background'
    end
  end
end
