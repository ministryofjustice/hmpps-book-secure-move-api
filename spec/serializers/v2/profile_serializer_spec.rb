# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::ProfileSerializer do
  subject(:serializer) { described_class.new(profile) }

  let(:profile) { create(:profile, latest_nomis_booking_id: 2717111, last_synced_with_nomis: Time.now) }
  let(:adapter_options) { {} }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys }

  it 'contains type property' do
    expect(result[:data][:type]).to eql 'profiles'
  end

  it 'contains id property' do
    expect(result[:data][:id]).to eql profile.id
  end

  it 'contains last_synced_with_nomis' do
    expect(result[:data][:attributes][:last_synced_with_nomis]).to eql profile.last_synced_with_nomis.iso8601
  end

  it 'contains latest_nomis_booking_id' do
    expect(result[:data][:attributes][:latest_nomis_booking_id]).to eql profile.latest_nomis_booking_id
  end

  describe '#assessment_answers' do
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
      expect(result[:data][:attributes][:assessment_answers].map do |alert|
        alert[:title]
      end).to match_array [risk_alert_type.title, health_alert_type.title]
    end

    context 'with empty assessment_answers' do
      let(:profile) { create :profile }

      it 'contains an `assessment_answers` nested collection' do
        expect(result[:data][:attributes][:assessment_answers]).to be_empty
      end
    end
  end
end
