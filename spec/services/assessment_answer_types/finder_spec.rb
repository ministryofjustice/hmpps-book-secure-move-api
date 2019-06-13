# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentAnswerTypes::Finder do
  subject(:finder) { described_class.new(filter_params) }

  let!(:assessment_answer_type) { create :assessment_answer_type }
  let(:id) { assessment_answer_type.id }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'with matching `user_type` filter' do
      let(:filter_params) { { user_type: assessment_answer_type.user_type } }

      it 'returns profile attribute type matching `user_type`' do
        expect(finder.call.pluck(:id)).to eql [assessment_answer_type.id]
      end
    end

    context 'with mis-matching `user_type` filter' do
      let(:filter_params) { { user_type: 'not a user type' } }

      it 'returns empty result set' do
        expect(finder.call.to_a).to eql []
      end
    end

    context 'with matching `category` filter' do
      let(:filter_params) { { category: assessment_answer_type.category } }

      it 'returns profile attribute type matching `category`' do
        expect(finder.call.pluck(:id)).to eql [assessment_answer_type.id]
      end
    end

    context 'with mis-matching `category` filter' do
      let(:filter_params) { { category: 'not a category' } }

      it 'returns empty result set' do
        expect(finder.call.to_a).to eql []
      end
    end
  end
end
