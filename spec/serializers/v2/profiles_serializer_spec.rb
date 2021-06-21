# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe V2::ProfilesSerializer do
  subject(:serializer) { described_class.new(profile, options) }

  let(:profile) { create(:profile) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:options) { {} }

  let(:expected_document) do
    {
      data: {
        id: profile.id,
        type: 'profiles',
        attributes: { assessment_answers: [] },
        relationships: {
          person: {
            data: { id: profile.person.id, type: 'people' },
          },
          category: {
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

  context 'with included person escort record' do
    let(:options) { { params: { included: %i[person_escort_record category] } } }
    let(:category) { create(:category) }
    let(:profile) { create(:profile, category: category) }

    it 'contains a nil `person_escort_record` relationship if no person escort record present' do
      expect(result[:data][:relationships][:person_escort_record][:data]).to be_nil
    end

    it 'contains a`person_escort_record` relationship with person escort record' do
      person_escort_record = create(:person_escort_record, profile: profile)

      expect(result[:data][:relationships][:person_escort_record][:data]).to eq({
        id: person_escort_record.id,
        type: 'person_escort_records',
      })
    end

    it 'contains a`category` relationship with category record' do
      expect(result[:data][:relationships][:category][:data]).to eq({
        id: category.id,
        type: 'categories',
      })
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
