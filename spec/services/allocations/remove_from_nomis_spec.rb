require 'rails_helper'

RSpec.describe Allocations::RemoveFromNomis do
  context 'when move is valid' do
    subject(:remove_transfer_from_nomis) { described_class.call(move) }

    let(:from_location) { create(:location, :prison) }
    let(:to_location) { create(:location, :prison) }
    let(:move) do
      create(
        :move,
        :prison_transfer,
        nomis_event_id: nomis_event_id,
        from_location: from_location,
        to_location: to_location,
      )
    end

    let(:booking_id) { 123 }
    let(:nomis_event_id) { 456 }
    let(:response_body) { '' }

    before do
      allow(NomisClient::Allocations).to receive(:put)
                                     .and_return(instance_double('OAuth2::Response', status: nomis_response_status, body: response_body))
      move.person.update(latest_nomis_booking_id: booking_id)
    end

    context 'when Nomis return 200 success' do
      let(:nomis_response_status) { 200 }
      let(:nomis_client_args) do
        {
          booking_id: booking_id,
          event_id: nomis_event_id,
          body_params: {
            'reasonCode': 'ADMI',
          },
        }
      end

      it 'removes the prison transfer event from Nomis' do
        remove_transfer_from_nomis

        expect(NomisClient::Allocations).to have_received(:put).with(nomis_client_args)
      end

      it 'clears the nomis_event_id' do
        remove_transfer_from_nomis

        expect(move.nomis_event_id).to be_nil
      end

      it 'returns debugging information' do
        expect(remove_transfer_from_nomis).to include(
          request_params: nomis_client_args,
          response_body: response_body,
          response_status: 200,
        )
      end
    end

    context 'when Nomis returns an error' do
      let(:nomis_response_status) { 400 }

      it 'does NOT clear nomis_event_id' do
        remove_transfer_from_nomis

        expect(move.nomis_event_id).to eq(nomis_event_id)
      end

      it 'returns debugging information' do
        expect(remove_transfer_from_nomis).to include(
          response_status: 400,
        )
      end
    end

    context 'when latest_booking_id is missing' do
      let(:nomis_response_status) { nil }
      let(:booking_id) { nil }

      it 'is nil' do
        expect(remove_transfer_from_nomis).to be_nil
      end
    end

    context 'when nomis_event_id is missing' do
      let(:nomis_response_status) { nil }
      let(:nomis_event_id) { nil }

      it 'is nil' do
        expect(remove_transfer_from_nomis).to be_nil
      end
    end
  end
end
