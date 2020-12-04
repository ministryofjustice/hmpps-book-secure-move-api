# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentQuestionSerializer do
  subject(:serializer) { described_class.new(assessment_question) }

  let(:disabled_at) { Time.new(2019, 1, 1) }
  let(:assessment_question) { create :assessment_question, disabled_at: disabled_at }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'assessment_questions'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql assessment_question.id
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql 'Sight Impaired'
  end

  it 'contains a category attribute' do
    expect(result[:data][:attributes][:category]).to eql 'health'
  end

  it 'contains a key attribute' do
    expect(result[:data][:attributes][:key]).to eql 'sight_impaired'
  end

  it 'contains a disabled_at attribute' do
    expect(result[:data][:attributes][:disabled_at]).to eql disabled_at.iso8601
  end
end
