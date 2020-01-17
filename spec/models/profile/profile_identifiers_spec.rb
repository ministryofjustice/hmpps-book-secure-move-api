# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile::ProfileIdentifiers, type: :model do
  subject(:profile_identifiers) { described_class.new(data) }

  let(:value) { 'ABC123456' }
  let(:data) do
    [
      {
        value: 'ABC123456',
        identifier_type: :police_national_computer,
      },
      {
        value: 'XYZ123456',
        identifier_type: :prison_number,
      },
    ]
  end

  describe '#to_a' do
    it 'contains correct number of items' do
      expect(profile_identifiers.to_a.size).to be 2
    end

    it 'converts the items to Profile::ProfileIdentifier objects' do
      expect(profile_identifiers.to_a).to all(be_a Profile::ProfileIdentifier)
    end

    context 'with an empty item' do
      subject(:profile_identifiers) { described_class.new(data + [{ value: '' }]) }

      it 'strips out the empty item' do
        expect(profile_identifiers.to_a.size).to be 2
      end
    end

    context 'with serialized input' do
      subject(:profile_identifiers) { described_class.new(data.to_json) }

      it 'parses JSON and contains correct number of items' do
        expect(profile_identifiers.to_a.size).to be 2
      end

      it 'parses JSON and converts the items to Profile::ProfileIdentifier objects' do
        expect(profile_identifiers.to_a).to all(be_a Profile::ProfileIdentifier)
      end
    end
  end
end
