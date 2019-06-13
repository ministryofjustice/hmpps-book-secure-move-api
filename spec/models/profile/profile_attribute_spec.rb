# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile::AssessmentAnswer, type: :model do
  subject(:assessment_answer) { described_class.new(attribute_values) }

  let(:description) { 'test' }
  let(:attribute_values) do
    {
      description: description,
      comments: 'just a test',
      assessment_answer_type_id: 123,
      date: Date.civil(2019, 5, 30),
      expiry_date: Date.civil(2019, 6, 30),
      category: 'risk',
      user_type: 'police'
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
    context 'when description is missing' do
      let(:description) { '' }

      it 'returns true' do
        expect(assessment_answer.empty?).to be true
      end
    end

    context 'when description is present' do
      let(:description) { 'test' }

      it 'returns false' do
        expect(assessment_answer.empty?).to be false
      end
    end
  end

  describe '#set_category_and_user_type' do
    let(:assessment_answer_type) { create :assessment_answer_type, category: 'health', user_type: 'prison' }
    let(:attribute_values) do
      {
        description: description,
        comments: 'just a test',
        assessment_answer_type_id: assessment_answer_type.id,
        date: Date.civil(2019, 5, 30),
        expiry_date: Date.civil(2019, 6, 30)
      }
    end

    before do
      assessment_answer.set_category_and_user_type
    end

    it 'sets the category' do
      expect(assessment_answer.category).to eql 'health'
    end

    it 'sets the user_type' do
      expect(assessment_answer.user_type).to eql 'prison'
    end
  end
end
