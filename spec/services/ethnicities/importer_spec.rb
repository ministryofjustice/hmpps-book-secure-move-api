# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ethnicities::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [
      {
        'domain' => 'ETHNICITY',
        'code' => 'A1',
        'description' => 'Asian/Asian British: Indian',
        'activeFlag' => 'Y'
      },
      {
        'domain' => 'ETHNICITY',
        'code' => 'W9',
        'description' => 'White: Any other background',
        'activeFlag' => 'Y'
      }
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Ethnicity, :count).by(2)
    end

    it 'creates a1' do
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
