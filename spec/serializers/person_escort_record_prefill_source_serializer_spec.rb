# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordPrefillSourceSerializer do
  subject(:serializer) { described_class.new(person_escort_record) }

  let(:person_escort_record) { create(:person_escort_record) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('person_escort_records')
  end
end
