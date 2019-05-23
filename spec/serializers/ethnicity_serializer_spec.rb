# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EthnicitySerializer do
  subject(:serializer) { described_class.new(ethnicity) }

  let(:ethnicity) { create :ethnicity }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'ethnicities'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql ethnicity.id
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:value]).to eql 'IC1'
  end
end
