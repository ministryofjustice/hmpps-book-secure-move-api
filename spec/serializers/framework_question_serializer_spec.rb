# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkQuestionSerializer do
  subject(:serializer) { described_class.new(framework_question) }

  let(:dependent_question) { create :framework_question }
  let(:framework_question) { create :framework_question, dependents: [dependent_question] }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer, include: includes).serializable_hash }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_questions')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_question.id)
  end

  it 'contains a `section` attribute' do
    expect(result[:data][:attributes][:section]).to eq(framework_question.section)
  end

  it 'contains a `key` attribute' do
    expect(result[:data][:attributes][:key]).to eq(framework_question.key)
  end

  it 'contains a `question_type` attribute' do
    expect(result[:data][:attributes][:question_type]).to eq(framework_question.question_type)
  end

  it 'contains a `options` attribute' do
    expect(result[:data][:attributes][:options]).to eq(framework_question.options)
  end

  it 'contains a `framework` relationship' do
    expect(result[:data][:relationships][:framework][:data]).to eq(
      id: framework_question.framework.id,
      type: 'frameworks',
    )
  end

  it 'contains a `descendants` relationship' do
    expect(result[:data][:relationships][:descendants][:data]).to contain_exactly(
      id: dependent_question.id,
      type: 'framework_questions',
    )
  end

  describe 'response_type' do
    context 'when question is of type radio with followup_comments' do
      let(:framework_question) { create(:framework_question, followup_comment: true) }

      it 'returns response_type `object`' do
        expect(result[:data][:attributes][:response_type]).to eq('object')
      end
    end

    context 'when response is of type radio' do
      let(:framework_question) { create(:framework_question) }

      it 'returns response_type `string`' do
        expect(result[:data][:attributes][:response_type]).to eq('string')
      end
    end

    context 'when question is of type checkbox with followup_comments' do
      let(:framework_question) { create(:framework_question, :checkbox, followup_comment: true) }

      it 'returns response_type `collection`' do
        expect(result[:data][:attributes][:response_type]).to eq('collection')
      end
    end

    context 'when question is of type checkbox' do
      let(:framework_question) { create(:framework_question, :checkbox) }

      it 'returns response_type `array`' do
        expect(result[:data][:attributes][:response_type]).to eq('array')
      end
    end

    context 'when question is of type `add_multiple_items`' do
      let(:framework_question) { create(:framework_question, :add_multiple_items) }

      it 'returns response_type `collection::add_multiple_items`' do
        expect(result[:data][:attributes][:response_type]).to eq('collection::add_multiple_items')
      end
    end

    context 'when question is of type text' do
      let(:framework_question) { create(:framework_question, :text) }

      it 'returns response_type `string`' do
        expect(result[:data][:attributes][:response_type]).to eq('string')
      end
    end
  end

  context 'with include options' do
    let(:includes) { { framework: :name, descendants: :question_type } }

    let(:expected_json) do
      [
        {
          id: framework_question.framework.id,
          type: 'frameworks',
          attributes: { name: framework_question.framework.name },
        },
        {
          id: dependent_question.id,
          type: 'framework_questions',
          attributes: { question_type: dependent_question.question_type },
        },
      ]
    end

    it 'contains an included framework' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
