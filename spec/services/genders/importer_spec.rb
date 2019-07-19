# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Genders::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    [
      {
        key: 'F',
        title: 'Female'
      },
      {
        key: 'R',
        title: 'Refused'
      },
      {
        key: 'NK',
        title: 'Not Known'
      }
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Gender, :count).by(5)
    end

    it 'creates F' do
      importer.call
      expect(Gender.find_by(key: 'F', title: 'Female')).to be_present
    end

    it 'creates M' do
      importer.call
      expect(Gender.find_by(key: 'M', title: 'Male')).to be_present
    end

    it 'creates R' do
      importer.call
      expect(Gender.find_by(key: 'R', title: 'Refused')).to be_present
    end
  end

  context 'with one existing record' do
    before do
      Gender.create!(key: 'M', title: 'Male')
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(Gender, :count).by(4)
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

  context 'with additional items containing a conflicting title' do
    let(:input_data) do
      [
        {
          key: 'M',
          title: 'Mail'
        }
      ]
    end

    it 'DOES NOT update the title of the visible record' do
      importer.call
      expect(Gender.find_by(key: 'M', title: 'Male')).to be_present
    end
  end
end
