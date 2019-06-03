# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonSerializer do
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
    expect(result[:data][:attributes][:first_names]).to eql 'Bob'
  end

  it 'contains a last_name attribute' do
    expect(result[:data][:attributes][:last_name]).to eql 'Roberts'
  end

  describe '#profile attributes' do
    let(:risk_alert_type) do
      create :profile_attribute_type, :risk
    end
    let(:health_alert_type) do
      create :profile_attribute_type, :health
    end
    let(:court_information_type) do
      create :profile_attribute_type, :court_information
    end

    let(:risk_alert) do
      {
        description: 'Escape risk',
        comments: 'Former miner',
        profile_attribute_type_id: risk_alert_type.id
      }
    end

    let(:health_alert) do
      {
        description: 'Medication',
        comments: 'Needs something for a headache',
        profile_attribute_type_id: health_alert_type.id
      }
    end

    let(:court_information) do
      {
        description: 'Interpreter required',
        comments: 'Only speaks Spanish',
        profile_attribute_type_id: court_information_type.id
      }
    end

    before do
      profile = person.latest_profile
      profile.profile_attributes = [
        risk_alert,
        health_alert,
        court_information
      ]
      profile.save!
    end

    it 'contains a `risk_alerts` nested collection' do
      expect(result[:data][:attributes][:risk_alerts].map do |alert|
        alert[:description]
      end).to eql ['Escape risk']
    end

    it 'contains a `health_alerts` nested collection' do
      expect(result[:data][:attributes][:health_alerts].map do |alert|
        alert[:description]
      end).to eql ['Medication']
    end

    it 'contains a `court_information` nested collection' do
      expect(result[:data][:attributes][:court_information].map do |alert|
        alert[:description]
      end).to eql ['Interpreter required']
    end
  end

  describe '#identifiers' do
    let(:profile_identifiers) do
      [
        {
          value: 'ABC123456',
          identifier_type: 'pnc_number'
        },
        {
          value: 'XYZ123456',
          identifier_type: 'prison_number'
        }
      ]
    end

    before do
      profile = person.latest_profile
      profile.profile_identifiers = profile_identifiers
      profile.save!
    end

    it 'contains two identifiers' do
      expect(result[:data][:attributes][:identifiers]).to eql profile_identifiers
    end
  end

  describe 'ethnicity' do
    let(:adapter_options) { { include: { ethnicity: %I[code title description] } } }
    let(:ethnicity) { person.latest_profile&.ethnicity }
    let(:expected_json) do
      [
        {
          id: ethnicity&.id,
          type: 'ethnicities',
          attributes: {
            code: ethnicity&.code,
            title: ethnicity&.title,
            description: ethnicity&.description
          }
        }
      ]
    end

    it 'contains an included ethnicity' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end

  describe 'gender' do
    let(:adapter_options) { { include: { gender: %I[title description] } } }
    let(:gender) { person.latest_profile&.gender }
    let(:expected_json) do
      [
        {
          id: gender&.id,
          type: 'genders',
          attributes: {
            title: gender&.title,
            description: gender&.description
          }
        }
      ]
    end

    it 'contains an included gender' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end
end
