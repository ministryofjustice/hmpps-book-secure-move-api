require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe CourtHearings::CreateInNomis do
  context 'when court hearing are valid' do
    subject(:create_hearing_in_nomis) { described_class.call(move, court_hearings) }

    let(:move) do
      create(
        :move,
        from_location: create(:location, nomis_agency_id: from_nomis_agency_id),
        to_location: create(:location, nomis_agency_id: to_nomis_agency_id),
      )
    end

    let(:court_hearings) do
      [
        create(:court_hearing, nomis_case_id: nomis_case_id, move: move, start_time: hearing_date_time, comments: comments),
      ]
    end

    let(:nomis_case_id) { 1_111_111 }
    let(:from_nomis_agency_id) { 'LEI' }
    let(:to_nomis_agency_id) { 'LEEDCC' }
    let(:hearing_date_time) { Time.zone.parse('2020-04-15T17:36:02+01:00') }
    let(:comments) { 'Restricted access to parking level.' }
    let(:booking_id) { 123 }

    before do
      allow(NomisClient::CourtHearings).to receive(:post)
                                              .and_return(instance_double('OAuth2::Response', status: nomis_response_status, body: { 'id' => 123 }.to_json))
      move.person.update(latest_nomis_booking_id: booking_id)
    end

    context 'when Nomis return 201 success' do
      let(:nomis_response_status) { 201 }
      let(:nomis_client_args) do
        [
          booking_id: booking_id,
          court_case_id: nomis_case_id,
          body_params: {
            'fromPrisonLocation': from_nomis_agency_id,
            'toCourtLocation': to_nomis_agency_id,
            'courtHearingDateTime': '2020-04-15T17:36:02',
            'comments': comments,
          },
        ]
      end

      it 'creates the court hearings in Nomis' do
        create_hearing_in_nomis

        expect(NomisClient::CourtHearings).to have_received(:post).with(*nomis_client_args)
      end

      it 'updates the nomis_hearing_id and saved_to_nomis' do
        create_hearing_in_nomis

        court_hearing = court_hearings.first
        expect(court_hearing.saved_to_nomis).to eq true
        expect(court_hearing.nomis_hearing_id).to eq 123
      end
    end

    context 'when Nomis returns an error' do
      let(:nomis_response_status) { 400 }

      it 'does NOT set nomis_hearing_id and saved_to_nomis' do
        create_hearing_in_nomis

        court_hearing = court_hearings.first
        expect(court_hearing.saved_to_nomis).to eq false
        expect(court_hearing.nomis_hearing_id).to be_nil
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
