require 'rails_helper'

RSpec.describe 'Access logs' do
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:headers) do
    {
      'Content-Type' => content_type,
      'Authorization' => "Bearer #{access_token}",
      'Idempotency-Key' => SecureRandom.uuid,
    }
  end

  let(:access_log) { AccessLog.order(:timestamp).last }

  xcontext 'when listing moves' do
    before { get '/api/moves', headers: }

    it 'logs the correct response code' do
      expect(access_log.code).to eq('200')
    end
  end

  xcontext 'when creating a move' do
    let(:move_attributes) do
      { date: Time.zone.today,
        time_due: Time.zone.now,
        status: 'requested',
        additional_information: 'some more info',
        move_type: 'court_appearance' }
    end

    let(:from_location) { create :location, suppliers: [supplier] }
    let(:to_location) { create :location, :court }
    let(:person) { create(:person) }
    let(:reason) { create(:prison_transfer_reason) }
    let(:supplier) { create(:supplier) }
    let(:data) do
      {
        type: 'moves',
        attributes: move_attributes,
        relationships: {
          person: { data: { type: 'people', id: person.id } },
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: to_location ? { data: { type: 'locations', id: to_location.id } } : { data: nil },
          prison_transfer_reason: { data: { type: 'prison_transfer_reasons', id: reason.id } },
        },
      }
    end

    before { post '/api/moves', params: { data: }, headers:, as: :json }

    it 'logs the correct response code' do
      expect(access_log.code).to eq('201')
    end

    context 'when invalid move type' do
      let(:move_attributes) do
        {
          date: Time.zone.today,
          time_due: Time.zone.now,
          status: 'requested',
          additional_information: 'some more info',
          move_type: 'wrong',
        }
      end

      it 'logs the correct response code' do
        expect(access_log.code).to eq('422')
      end
    end

    context 'when invalid status' do
      let(:move_attributes) do
        {
          date: Time.zone.today,
          time_due: Time.zone.now,
          status: 'blahblah',
          additional_information: 'some more info',
          move_type: 'court_appearance',
        }
      end

      it 'logs the correct response code' do
        expect(access_log.code).to eq('422')
      end
    end
  end
end
