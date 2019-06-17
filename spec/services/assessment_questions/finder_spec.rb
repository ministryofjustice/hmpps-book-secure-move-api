# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentQuestions::Finder do
  subject(:finder) { described_class.new(filter_params) }

  let!(:assessment_question) { create :assessment_question }
  let(:id) { assessment_question.id }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'with matching `category` filter' do
      let(:filter_params) { { category: assessment_question.category } }

      it 'returns assessment questions matching `category`' do
        expect(finder.call.pluck(:id)).to eql [assessment_question.id]
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
