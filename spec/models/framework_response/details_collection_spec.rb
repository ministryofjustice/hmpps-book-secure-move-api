# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::DetailsCollection, type: :model do
  context 'with validations' do
    it 'validates the details object passed' do
      collection = [{ option: 'No' }, { option: 'Yes' }]
      details_collection = described_class.new(collection:, question_options: %w[No])

      expect(details_collection).not_to be_valid
      expect(details_collection.errors.messages[:option]).to eq(['is not included in the list'])
    end

    it 'validates uniqueness of options' do
      collection = [{ option: 'No', details: 'some detail' }, { option: 'No' }]
      details_collection = described_class.new(collection:, question_options: %w[No])

      expect(details_collection).not_to be_valid
      expect(details_collection.errors.messages[:option]).to eq(['Duplicate options selected'])
    end
  end

  describe '#to_a' do
    it 'returns collection of detail objects' do
      collection = [
        {
          option: 'Level 1',
          details: 'some comment',
        },
        {
          option: 'Level 2',
          details: 'some comment',
        },
      ]

      details_collection = described_class.new(collection:)
      expect(details_collection.to_a.first).to be_a(FrameworkResponse::DetailsObject)
    end

    it 'maps collection of detail objects' do
      collection = [
        {
          option: 'Level 1',
          details: 'some comment',
        },
        {
          option: 'Level 2',
          details: 'some comment',
        },
      ]

      details_collection = described_class.new(collection:)
      expect(details_collection.to_a.count).to eq(2)
    end

    it 'returns an empty array if collection is empty' do
      details_collection = described_class.new(collection: [])

      expect(details_collection.to_a).to be_empty
    end
  end
end
