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

  describe '#assessment_answers' do
    let(:risk_alert_type) do
      create :assessment_question, :risk
    end
    let(:health_alert_type) do
      create :assessment_question, :health
    end
    let(:court_type) do
      create :assessment_question, :court
    end

    let(:risk_alert) do
      {
        title: risk_alert_type.title,
        comments: 'Former miner',
        assessment_question_id: risk_alert_type.id,
      }
    end

    let(:health_alert) do
      {
        title: health_alert_type.title,
        comments: 'Needs something for a headache',
        assessment_question_id: health_alert_type.id,
      }
    end

    let(:court) do
      {
        title: court_type.title,
        comments: 'Only speaks Spanish',
        assessment_question_id: court_type.id,
      }
    end

    before do
      profile = person.latest_profile
      profile.assessment_answers = [
        risk_alert,
        health_alert,
        court,
      ]
      profile.save!
    end

    it 'contains an `assessment_answers` nested collection' do
      expect(result[:data][:attributes][:assessment_answers].map do |alert|
        alert[:title]
      end).to match_array [risk_alert_type.title, health_alert_type.title, court_type.title]
    end
  end

  describe '#identifiers' do
    let(:profile_identifiers) do
      [
        {
          value: 'ABC123456',
          identifier_type: 'police_national_computer',
        },
        {
          value: 'XYZ123456',
          identifier_type: 'prison_number',
        },
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
    let(:adapter_options) { { include: { ethnicity: %I[key title description] } } }
    let(:ethnicity) { person.latest_profile&.ethnicity }
    let(:expected_json) do
      [
        {
          id: ethnicity&.id,
          type: 'ethnicities',
          attributes: {
            key: ethnicity&.key,
            title: ethnicity&.title,
            description: ethnicity&.description,
          },
        },
      ]
    end

    it 'contains an included ethnicity' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end

  describe 'gender' do
    before do
      person.latest_profile.update(gender_additional_information: gender_additional_information)
    end

    let(:adapter_options) { { include: { gender: %I[title description] } } }
    let(:gender) { person.latest_profile&.gender }
    let(:gender_additional_information) { 'more info about the person' }
    let(:expected_json) do
      [
        {
          id: gender&.id,
          type: 'genders',
          attributes: {
            title: gender&.title,
            description: gender&.description,
          },
        },
      ]
    end

    it 'contains an included gender' do
      expect(result[:included]).to(include_json(expected_json))
    end

    it 'contains gender_additional_information' do
      expect(result[:data][:attributes][:gender_additional_information]).to eql gender_additional_information
    end
  end
end
