require 'rails_helper'

RSpec.describe CourtHearings::CreateInNomis do
  context 'when court hearing are valid' do
    subject(:create_hearing_in_nomis) { described_class.call(move, court_hearings) }

    let(:move) {
      create(:move,
             from_location: create(:location, nomis_agency_id: from_nomis_agency_id),
             to_location: create(:location, nomis_agency_id: to_nomis_agency_id))
    }

    let(:court_hearings) {
      [
        create(:court_hearing, nomis_case_id: nomis_case_id, move: move, start_time: hearing_date_time, comments: comments),
      ]
    }

    let(:nomis_case_id) { 1111111 }
    let(:from_nomis_agency_id) { 'LEI' }
    let(:to_nomis_agency_id) { 'LEEDCC' }
    let(:hearing_date_time) { Time.new(2020, 12, 1).iso8601 }
    let(:comments) { 'Restricted access to parking level.' }
    let(:booking_id) { 123 }

    before do
      allow(NomisClient::CourtHearing).to receive(:post)
      move.person.latest_profile.update(latest_nomis_booking_id: booking_id)
    end

    it 'creates the court hearings in Nomis' do
      create_hearing_in_nomis

      expect(NomisClient::CourtHearing).to have_received(:post).with(
        booking_id: booking_id,
        court_case_id: nomis_case_id,
        body_params: {
            'fromPrisonLocation': from_nomis_agency_id, 'toCourtLocation': to_nomis_agency_id,
            'courtHearingDateTime': hearing_date_time, 'comments': comments
        },
      )
    end
  end
end
