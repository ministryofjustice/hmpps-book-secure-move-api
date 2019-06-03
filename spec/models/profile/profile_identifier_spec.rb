# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile::ProfileIdentifier, type: :model do
  subject(:profile_identifier) { described_class.new(attribute_values) }

  let(:value) { 'ABC123456' }
  let(:attribute_values) do
    {
      value: value,
      identifier_type: 'pnc_number'
    }
  end

  describe '#as_json' do
    it 'returns a hash of all values' do
      expect(profile_identifier.as_json).to eql attribute_values
    end
  end

  describe '#empty' do
    context 'when value is missing' do
      let(:value) { '' }

      it 'returns true' do
        expect(profile_identifier.empty?).to be true
      end
    end

    context 'when value is present' do
      let(:value) { 'test' }

      it 'returns false' do
        expect(profile_identifier.empty?).to be false
      end
    end
  end
end
