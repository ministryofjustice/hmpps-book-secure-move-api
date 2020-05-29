# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::PersonSerializer do
  subject(:serializer) { described_class.new(person) }

  let(:person) { create :person }
  let(:adapter_options) { {} }
  let(:result) do
    JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
  end

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'people'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql person.id
  end

  it 'contains a first_names attribute' do
    expect(result[:data][:attributes][:first_names]).to eql person.first_names
  end

  it 'contains a last_name attribute' do
    expect(result[:data][:attributes][:last_name]).to eql person.last_name
  end

  it 'contains a date_of_birth attribute' do
    expect(result[:data][:attributes][:date_of_birth]).to eql person.date_of_birth.iso8601
  end

  describe 'ethnicity' do
    let(:adapter_options) { { include: :ethnicity } }

      it 'contains a relationship to ethnicity' do
        expect(result[:data][:relationships]).to include(:ethnicity)
      end

    context 'with the ethnicity' do
      it 'contains an included ethnicity' do
        expect(result[:included].map { |r| r[:type] }).to contain_exactly('ethnicities')
      end
    end

    context 'without the ethnicity' do
      let(:person) { create(:person, ethnicity: nil) }

      it 'does not contain an included ethnicity' do
        expect(result[:included]).to be_nil
      end
    end
  end

  describe 'gender' do
    let(:adapter_options) { { include: :gender } }

      it 'contains a relationship to gender' do
        expect(result[:data][:relationships]).to include(:gender)
      end

    context 'with the gender' do
      it 'contains an included gender' do
        expect(result[:included].map { |r| r[:type] }).to contain_exactly('genders')
      end
    end

    context 'without the gender' do
      let(:person) { create(:person, gender: nil) }

      it 'does not contain an included gender' do
        expect(result[:included]).to be_nil
      end
    end
  end

  describe 'profiles' do
    let(:adapter_options) { { include: :profiles } }

      it 'contains a relationship to profiles' do
        expect(result[:data][:relationships]).to include(:profiles)
      end

    context 'with profiles' do
      it 'contains an included gender' do
        expect(result[:included].map { |r| r[:type] }).to contain_exactly('profiles')
      end
    end

    context 'without profiles' do
      let(:person) { create(:person, profiles: []) }

      it 'does not contain included profiles' do
        expect(result[:included]).to be_nil
      end
    end
  end
end
