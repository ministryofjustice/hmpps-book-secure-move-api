# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Activities, with_nomis_client_authentication: true do
  describe '.get' do
    subject(:activities_get) { described_class.get(booking_id, start_date, end_date) }

    let(:booking_id) { '1495077' }
    let(:start_date) { Time.zone.today }
    let(:end_date) { Date.tomorrow }

    let(:response_body) { file_fixture('nomis/get_activities_200.json').read }

    it 'calls the NomisClient::Base.get with the correct path and params' do
      activities_get

      expect(token).to have_received(:get).with(
        "/api/bookings/1495077/activities?fromDate=#{start_date.iso8601}&toDate=#{end_date.iso8601}",
        headers: { 'Page-Limit' => '1000' },
      )
    end

    it 'returns a parsed response body' do
      expect(activities_get).to be_a(Array)
    end
  end
end
