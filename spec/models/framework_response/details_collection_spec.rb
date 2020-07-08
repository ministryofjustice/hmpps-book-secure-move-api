# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::DetailsCollection, type: :model do
  it 'validates the details object passed' do
    collection = [{ option: 'No' }, { option: 'Yes' }]
    details_collection = described_class.new(collection: collection, question_options: %w[No])

    expect(details_collection).not_to be_valid
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

      details_collection = described_class.new(collection: collection)
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

      details_collection = described_class.new(collection: collection)
      expect(details_collection.to_a.count).to eq(2)
    end

    it 'returns an empty array if collection is empty' do
      details_collection = described_class.new(collection: [])

      expect(details_collection.to_a).to be_empty
    end
  end
end
