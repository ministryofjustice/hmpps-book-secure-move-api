# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveActivities do
  let(:person) { instance_double('Person', latest_nomis_booking_id: '12345') }
  let(:response_json) { JSON.parse(file_fixture('nomis_get_activities_200.json').read) }

  before do
    allow(NomisClient::Activities).to receive(:get).and_return(response_json)
  end

  it 'returns an array of CourtCase' do
    response = described_class.call(person)

    expect(response).to all(be_a(Activity))
  end

  it 'calls NomisClient::Activities with the correct booking id' do
    described_class.call(person)

    expect(NomisClient::Activities).to have_received(:get).with('12345')
  end
end
