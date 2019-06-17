# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile::AssessmentAnswer, type: :model do
  subject(:assessment_answer) { described_class.new(attribute_values) }

  let(:title) { 'test' }
  let(:attribute_values) do
    {
      title: title,
      comments: 'just a test',
      assessment_question_id: 123,
      date: Date.civil(2019, 5, 30),
      expiry_date: Date.civil(2019, 6, 30),
      category: 'risk'
    }
  end

  describe '#as_json' do
    it 'returns a hash of all values' do
      expect(assessment_answer.as_json).to eql attribute_values
    end
  end

  describe '#date=' do
    it 'converts strings to dates' do
      assessment_answer.date = '2019-05-30'
      expect(assessment_answer.date).to eql Date.civil(2019, 5, 30)
    end

    it 'stores dates as they are' do
      assessment_answer.date = Date.civil(2019, 5, 30)
      expect(assessment_answer.date).to eql Date.civil(2019, 5, 30)
    end
  end

  describe '#expiry_date=' do
    it 'converts strings to dates' do
      assessment_answer.expiry_date = '2019-05-30'
      expect(assessment_answer.expiry_date).to eql Date.civil(2019, 5, 30)
    end

    it 'stores dates as they are' do
      assessment_answer.expiry_date = Date.civil(2019, 5, 30)
      expect(assessment_answer.expiry_date).to eql Date.civil(2019, 5, 30)
    end
  end

  describe '#empty?' do
    context 'when title is missing' do
      let(:title) { '' }

      it 'returns true' do
        expect(assessment_answer.empty?).to be true
      end
    end

    context 'when title is present' do
      let(:title) { 'test' }

      it 'returns false' do
        expect(assessment_answer.empty?).to be false
      end
    end
  end

  describe '#set_category' do
    let(:assessment_question) { create :assessment_question, category: 'health' }
    let(:attribute_values) do
      {
        title: title,
        comments: 'just a test',
        assessment_question_id: assessment_question.id,
        date: Date.civil(2019, 5, 30),
        expiry_date: Date.civil(2019, 6, 30)
      }
    end

    before do
      assessment_answer.set_category
    end

    it 'sets the category' do
      expect(assessment_answer.category).to eql 'health'
    end
  end
end
