# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::CourtCases, with_nomis_client_authentication: true do
  describe '.get' do
    let(:nomis_client) { class_double(NomisClient::Base).as_stubbed_const }

    let(:booking_id) { '1495077' }

    it '#get' do
      allow(nomis_client).to receive(:get).and_return(instance_double('OAuth2::Response', body: response_body))

      described_class.get(booking_id)

      expect(nomis_client).to have_received(:get).with("/bookings/#{booking_id}/court-cases?activeOnly=true")
    end
  end
end
