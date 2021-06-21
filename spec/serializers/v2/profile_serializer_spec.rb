# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::ProfileSerializer do
  subject(:serializer) { described_class.new(profile, adapter_options) }

  let(:profile) { create(:profile) }
  let(:adapter_options) { {} }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  let(:expected_document) do
    {
      data: {
        id: profile.id,
        type: 'profiles',
        attributes: { assessment_answers: [], csra: nil, requires_youth_risk_assessment: nil },
        relationships: {
          category: {
            data: nil,
          },
          person: {
            data: { id: profile.person.id, type: 'people' },
          },
          documents: {
            data: [],
          },
          person_escort_record: {
            data: nil,
          },
          youth_risk_assessment: {
            data: nil,
          },
        },
      },
    }
  end

  it 'returns the expected serialized `Profile`' do
    expect(result).to eq(expected_document)
  end

  context 'with assessment_answers' do
    let(:risk_alert_type) { create :assessment_question, :risk }
    let(:health_alert_type) { create :assessment_question, :health }

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

    let(:profile) { create(:profile, assessment_answers: [risk_alert, health_alert]) }

    it 'contains an `assessment_answers` nested collection' do
      assessment_answers = result[:data][:attributes][:assessment_answers].map { |alert| alert[:title] }

      expect(assessment_answers).to match_array [risk_alert_type.title, health_alert_type.title]
    end
  end

  describe 'with supported includes' do
    let(:category) { create(:category) }
    let(:profile) { create(:profile, documents: [create(:document)], category: category) }
    let(:adapter_options) { { include: %i[documents person category] } }
    let(:serialized_person) do
      serializer = V2::PersonSerializer.new(profile.person)

      JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys
    end

    let(:serialized_document) do
      serializer = DocumentSerializer.new(profile.documents.first)

      JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys
    end

    let(:serialized_category) do
      serializer = CategorySerializer.new(profile.category)

      JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys
    end

    let(:expected_document) do
      {
        data: {
          id: profile.id,
          type: 'profiles',
          attributes: { assessment_answers: [], csra: nil },
          relationships: {
            person: {
              data: { id: profile.person.id, type: 'people' },
            },
            documents: { data: [{ id: profile.documents.first.id, type: 'documents' }] },
            category: {
              data: { id: category.id, type: 'categories' },
            },
          },
        },
        included: UnorderedArray(serialized_person[:data], serialized_document[:data], serialized_category[:data]),
      }
    end

    before { ActiveStorage::Current.host = 'http://www.example.com' } # This is used in the serializer

    it 'returns the expected serialized `Profile`' do
      expect(result).to include_json(expected_document)
    end
  end

  describe 'with csra' do
    let(:profile) { create(:profile, csra: 'Standard') }

    let(:expected_document) do
      {
        data: {
          id: profile.id,
          type: 'profiles',
          attributes: { assessment_answers: [], csra: 'Standard', requires_youth_risk_assessment: nil },
          relationships: {
            category: {
              data: nil,
            },
            person: {
              data: { id: profile.person.id, type: 'people' },
            },
            documents: {
              data: [],
            },
            person_escort_record: {
              data: nil,
            },
            youth_risk_assessment: {
              data: nil,
            },
          },
        },
      }
    end

    it 'returns the expected serialized `Profile`' do
      expect(result).to include_json(expected_document)
    end
  end
end
