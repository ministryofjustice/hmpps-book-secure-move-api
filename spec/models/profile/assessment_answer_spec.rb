# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile::AssessmentAnswer, type: :model do
  subject(:assessment_answer) { described_class.new(attribute_values) }

  let(:title) { 'test' }
  let(:assessment_question_id) { 'c1913bca-04f2-4688-b372-a547db9a6ce8' }
  let(:attribute_values) do
    {
      title: title,
      comments: 'just a test',
      assessment_question_id: assessment_question_id,
      created_at: Date.civil(2019, 5, 30),
      expires_at: Date.civil(2019, 6, 30),
      category: 'risk',
      key: 'just_a_test'
    }
  end

  describe 'validations' do
    context 'without an assessment_question_id or nomis_alert_type and nomis_alert_code' do
      let(:attribute_values) do
        {
          title: title,
          comments: 'just a test'
        }
      end

      it 'is not valid' do
        expect(assessment_answer.valid?).to be false
      end
    end

    context 'with an assessment_question_id' do
      let(:attribute_values) do
        {
          assessment_question_id: 123
        }
      end

      it 'is valid' do
        expect(assessment_answer.valid?).to be true
      end
    end

    context 'with a nomis_alert_code and nomis_alert_type' do
      let(:attribute_values) do
        {
          nomis_alert_type: 'A',
          nomis_alert_code: 'ABC'
        }
      end

      it 'is valid' do
        expect(assessment_answer.valid?).to be true
      end
    end
  end

  describe '#as_json' do
    it 'returns a hash of all values' do
      expect(assessment_answer.as_json).to eql attribute_values
    end
  end

  describe '#created_at=' do
    it 'converts strings to dates' do
      assessment_answer.created_at = '2019-05-30'
      expect(assessment_answer.created_at).to eql Date.civil(2019, 5, 30)
    end

    it 'stores dates as they are' do
      assessment_answer.created_at = Date.civil(2019, 5, 30)
      expect(assessment_answer.created_at).to eql Date.civil(2019, 5, 30)
    end
  end

  describe '#expires_at=' do
    it 'converts strings to dates' do
      assessment_answer.expires_at = '2019-05-30'
      expect(assessment_answer.expires_at).to eql Date.civil(2019, 5, 30)
    end

    it 'stores dates as they are' do
      assessment_answer.expires_at = Date.civil(2019, 5, 30)
      expect(assessment_answer.expires_at).to eql Date.civil(2019, 5, 30)
    end
  end

  describe '#empty?' do
    context 'when assessment_question_id is missing' do
      let(:assessment_question_id) { '' }

      it 'returns true' do
        expect(assessment_answer.empty?).to be true
      end
    end

    context 'when assessment_question_id is present' do
      it 'returns false' do
        expect(assessment_answer.empty?).to be false
      end
    end
  end

  describe '#copy_question_attributes' do
    let(:assessment_question) { create :assessment_question, category: 'health', title: 'Sight Impaired' }
    let(:attribute_values) do
      {
        comments: 'just a test',
        assessment_question_id: assessment_question.id,
        created_at: Date.civil(2019, 5, 30),
        expires_at: Date.civil(2019, 6, 30),
        category: 'foo',
        title: 'foo'
      }
    end

    before do
      assessment_answer.copy_question_attributes
    end

    it 'sets the category' do
      expect(assessment_answer.category).to eql 'health'
    end

    it 'sets the key' do
      expect(assessment_answer.key).to eql 'sight_impaired'
    end

    it 'sets the title' do
      expect(assessment_answer.title).to eql 'Sight Impaired'
    end
  end

  describe '#set_timestamps' do
    let(:assessment_question) { create :assessment_question, category: 'health', title: 'Sight Impaired' }
    let(:initial_date) { nil }
    let(:initial_expiry_date) { nil }
    let(:attribute_values) do
      {
        comments: 'just a test',
        assessment_question_id: assessment_question.id,
        created_at: initial_date,
        expires_at: initial_expiry_date
      }
    end

    around do |example|
      Timecop.freeze
      example.run
      Timecop.return
    end

    before do
      assessment_answer.set_timestamps
    end

    context 'when #created_at is NOT already set' do
      it 'sets the #created_at attribute' do
        expect(assessment_answer.created_at).to be_present
      end
    end

    context 'when #created_at is already set' do
      let(:initial_date) { 2.days.ago }

      it 'does not overwrite the #created_at attribute' do
        expect(assessment_answer.created_at).to eql initial_date
      end
    end
  end
end
