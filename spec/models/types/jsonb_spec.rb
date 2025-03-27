# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Jsonb, type: :model do
  subject(:jsonb) { described_class.new(concrete_class) }

  let(:concrete_class) { Gender }
  let(:example) { build :gender }

  describe '#type' do
    it 'always returns :jsonb data type' do
      expect(jsonb.type).to eq :jsonb
    end
  end

  describe '#cast' do
    it 'casts value to concrete class' do
      expect(jsonb.cast(key: 'foo')).to be_a concrete_class
    end
  end

  describe '#deserialize' do
    subject(:deserialized) { jsonb.deserialize(value) }

    context 'with valid JSON' do
      let(:value) { example.as_json }

      it 'parses content and instantiates concrete class' do
        expect(deserialized).to be_a concrete_class
      end

      it 'contains correct parsed attributes' do
        expect(deserialized).to have_attributes(
          key: example.key,
          title: example.title,
        )
      end
    end

    context 'with invalid JSON' do
      let(:value) { 'foo' }

      it 'ignores parsing errors and instantiates concrete class' do
        expect(deserialized).to be_a concrete_class
      end

      it 'returns an empty concrete class instance' do
        expect(deserialized.key).to be_blank
      end
    end

    context 'with other types' do
      let(:value) { Hash.new({ foo: :bar }) }

      it 'returns an empty concrete class instance' do
        expect(deserialized.key).to be_blank
      end
    end
  end

  describe '#serialize' do
    subject(:serialized) { jsonb.serialize(value) }

    context 'with an array' do
      let(:value) { [example] }

      it 'returns correct JSON' do
        expect(serialized).to eq([example].to_json)
      end
    end

    context 'with a hash' do
      let(:value) { example.attributes }

      it 'returns correct JSON' do
        expect(serialized).to eq(example.to_json)
      end
    end

    context 'with a concrete class instance' do
      let(:value) { example }

      it 'returns correct JSON' do
        expect(serialized).to eq(example.to_json)
      end
    end

    context 'with another type' do
      let(:value) { 'foo' }

      it 'returns serialized original value' do
        expect(serialized).to eq 'foo'
      end
    end
  end
end
