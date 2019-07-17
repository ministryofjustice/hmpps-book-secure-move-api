# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Genders::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [
      {
        'domain' => 'SEX',
        'code' => 'F',
        'description' => 'Female',
        'activeFlag' => 'Y'
      },
      {
        'domain' => 'SEX',
        'code' => 'M',
        'description' => 'Male',
        'activeFlag' => 'Y'
      }
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Gender, :count).by(2)
    end

    it 'creates F' do
      importer.call
      expect(Gender.find_by(key: 'F', title: 'Female')).to be_present
    end

    it 'creates M' do
      importer.call
      expect(Gender.find_by(key: 'M', title: 'Male')).to be_present
    end
  end

  context 'with one existing record' do
    before do
      Gender.create!(key: 'M', title: 'Male')
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(Gender, :count).by(1)
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:male) do
      Gender.create!(key: 'M', title: 'Mail')
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(male.reload.title).to eq 'Male'
    end
  end
end
