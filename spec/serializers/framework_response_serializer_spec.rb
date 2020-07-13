# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponseSerializer do
  subject(:serializer) { described_class.new(framework_response) }

  let(:framework_response) { create :string_response }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer).serializable_hash }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_responses')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_response.id)
  end

  it 'contains a `value` attribute' do
    expect(result[:data][:attributes][:value]).to eq(framework_response.value)
  end

  it 'contains a `person_escort_record` relationship' do
    expect(result[:data][:relationships][:person_escort_record][:data]).to eq(
      id: framework_response.person_escort_record.id,
      type: 'person_escort_records',
    )
  end

  it 'contains a `question` relationship' do
    expect(result[:data][:relationships][:question][:data]).to eq(
      id: framework_response.framework_question.id,
      type: 'framework_questions',
    )
  end

  describe 'value_type' do
    context 'when response is an object response' do
      let(:framework_response) { create(:object_response) }

      it 'returns value_type `object`' do
        expect(result[:data][:attributes][:value_type]).to eq('object')
      end
    end

    context 'when response is an string response' do
      let(:framework_response) { create(:string_response) }

      it 'returns value_type `string`' do
        expect(result[:data][:attributes][:value_type]).to eq('string')
      end
    end

    context 'when response is an collection response' do
      let(:framework_response) { create(:collection_response) }

      it 'returns value_type `collection`' do
        expect(result[:data][:attributes][:value_type]).to eq('collection')
      end
    end

    context 'when response is an array response' do
      let(:framework_response) { create(:array_response) }

      it 'returns value_type `array`' do
        expect(result[:data][:attributes][:value_type]).to eq('array')
      end
    end
  end
end
