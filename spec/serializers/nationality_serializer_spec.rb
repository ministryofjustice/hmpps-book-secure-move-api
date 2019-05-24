# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NationalitySerializer do
  subject(:serializer) { described_class.new(nationality) }

  let(:nationality) { create :nationality }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'nationalities'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql nationality.id
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql 'British'
  end
end
