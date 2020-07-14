# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordSerializer do
  subject(:serializer) { described_class.new(person_escort_record) }

  let(:person_escort_record) { create :person_escort_record }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer).serializable_hash }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('person_escort_records')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(person_escort_record.id)
  end

  it 'contains a `status` attribute' do
    expect(result[:data][:attributes][:status]).to eq('in_progress')
  end

  it 'contains a `version` attribute' do
    expect(result[:data][:attributes][:version]).to eq(person_escort_record.framework.version)
  end

  it 'contains a `profile` relationship' do
    expect(result[:data][:relationships][:profile][:data]).to eq(
      id: person_escort_record.profile.id,
      type: 'profiles',
    )
  end

  it 'contains a `framework` relationship' do
    expect(result[:data][:relationships][:framework][:data]).to eq(
      id: person_escort_record.framework.id,
      type: 'frameworks',
    )
  end

  it 'contains an empty `responses` relationship if no responses present' do
    expect(result[:data][:relationships][:responses][:data]).to be_empty
  end

  it 'contains a`responses` relationship with framework responses' do
    question = create(:framework_question)
    response = serializer.framework_responses.create!(type: 'FrameworkResponse::String', framework_question: question)

    expect(result[:data][:relationships][:responses][:data]).to contain_exactly(
      id: response.id,
      type: 'framework_responses',
    )
  end
end
