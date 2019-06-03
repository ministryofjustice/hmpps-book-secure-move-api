# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile::ProfileAttributes, type: :model do
  subject(:profile_attributes) { described_class.new(data) }

  let(:description) { 'test' }
  let(:data) do
    [
      {
        description: description,
        comments: 'just a test',
        profile_attribute_type_id: 123,
        date: Date.civil(2019, 6, 30),
        expiry_date: Date.civil(2019, 7, 30)
      },
      {
        description: description,
        comments: 'just a test',
        profile_attribute_type_id: 456,
        date: Date.civil(2019, 5, 30),
        expiry_date: Date.civil(2019, 6, 30)
      }
    ]
  end

  describe '#to_a' do
    it 'contains correct number of items' do
      expect(profile_attributes.to_a.size).to be 2
    end

    it 'converts the items to Profile::ProfileAttribute objects' do
      expect(profile_attributes.to_a).to all(be_a Profile::ProfileAttribute)
    end

    context 'with an empty item' do
      subject(:profile_attributes) { described_class.new(data + [{ description: '' }]) }

      it 'strips out the empty item' do
        expect(profile_attributes.to_a.size).to be 2
      end
    end

    context 'with serialized input' do
      subject(:profile_attributes) { described_class.new(data.to_json) }

      it 'parses JSON and contains correct number of items' do
        expect(profile_attributes.to_a.size).to be 2
      end

      it 'parses JSON and converts the items to Profile::ProfileAttribute objects' do
        expect(profile_attributes.to_a).to all(be_a Profile::ProfileAttribute)
      end
    end
  end
end
