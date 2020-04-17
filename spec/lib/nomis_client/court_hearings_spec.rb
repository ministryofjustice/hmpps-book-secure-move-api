# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::CourtHearing do
  describe '.post' do
    subject(:court_hearing_post) {
      described_class.post(booking_id: booking_id, court_case_id: court_case_id, body_params: {})
    }

    let(:booking_id) { 1111 }
    let(:court_case_id) { 2222 }

    it 'creates prison-to-court-hearing in Nomis ' do
      allow(NomisClient::Base).to receive(:post).and_return(instance_double('OAuth2::Response', body: nil))

      court_hearing_post

      expect(NomisClient::Base).to have_received(:post)
                                       .with("/bookings/#{booking_id}/court-cases/#{court_case_id}/prison-to-court-hearings", body: '{}')
    end

    context 'when Nomis returns an error' do
      it 'pushes error the warning to Sentry' do
        allow(Raven).to receive(:capture_message)

        court_hearing_post

        expect(Raven).to have_received(:capture_message)
      end
    end
  end
end
