# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('post_event_responses.yaml', version: 'v2') }
  let(:supplier) { create(:supplier, name: 'serco') }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'POST /events' do
    let(:event_attributes) do
      {
        occurred_at: Time.zone.now,
        recorded_at: Time.zone.now,
        notes: 'Something or other',
        event_type: 'MoveCancel',
        details: {
          cancellation_reason: Move::CANCELLATION_REASON_MADE_IN_ERROR,
          cancellation_reason_comment: 'The flibble got wibbled',
        },
      }
    end

    let(:move) { create(:move) }

    let(:data) do
      {
        type: 'events',
        attributes: event_attributes,
        relationships: {
          eventable: { data: { type: 'moves', id: move.id } },
        },
      }
    end

    it_behaves_like 'an endpoint that responds with success 201' do
      before { do_post }
    end

    it 'creates a event' do
      expect { do_post }.to change(GenericEvent, :count).by(1)
    end

    it 'sets the eventable' do
      expect { do_post }.to change { GenericEvent.find_by(eventable_id: move.id, eventable_type: 'Move') }.from(nil).to(be_a(GenericEvent))
    end

    it 'returns serialized data' do
      do_post

      event = GenericEvent.last
      resource_to_json = JSON.parse(ActionController::Base.render(json: event, serializer: GenericEventSerializer))

      expect(response_json).to eq resource_to_json
    end

    it 'sets the created_by' do
      do_post
      event = GenericEvent.find(response_json.dig('data', 'id'))
      expect(event.created_by).to eq('unknown')
    end

    context 'when using a real access token' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }

      it 'sets the created_by' do
        do_post
        event = GenericEvent.find(response_json.dig('data', 'id'))
        expect(event.created_by).to eq('serco')
      end
    end

    context 'when supplying a reference to a non-existent relationship' do
      let(:data) do
        {
          type: 'events',
          attributes: event_attributes,
          relationships: {
            eventable: { data: { type: 'moves', id: 'foo' } },
          },
        }
      end

      let(:detail_404) { "Couldn't find Move with 'id'=foo" }

      it_behaves_like 'an endpoint that responds with error 404' do
        before { do_post }
      end
    end

    context 'when specifying invalid attributes' do
      let(:data) do
        {
          type: 'events',
          attributes: event_attributes,
          relationships: {
            eventable: { data: { type: 'movess', id: move.id } },
          },
        }
      end
      let(:errors_422) do
        [
          {
            'title' => 'Invalid occurred_at, recorded_at, event_type, eventable_type',
            'detail' => "Validation failed: Occurred at can't be blank, Occurred at must be formatted as a valid ISO-8601 date-time, Recorded at can't be blank, Recorded at must be formatted as a valid ISO-8601 date-time, Event type is not included in the list, Eventable type is not included in the list",
          },
        ]
      end

      let(:event_attributes) { attributes_for(:event).merge(event_type: 'Event::FooBar') }

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end
  end

  def do_post
    post '/api/events', params: { data: data }, headers: headers, as: :json
  end
end
