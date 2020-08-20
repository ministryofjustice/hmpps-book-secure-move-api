# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::EventsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('post_event_responses.yaml', version: 'v2') }
  let(:supplier) { create(:supplier) }
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
        client_timestamp: Time.zone.now,
        notes: 'Something or other',
        event_type: 'MoveCancelV2',
        details: {
          cancellation_reason: Move::CANCELLATION_REASON_MADE_IN_ERROR,
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
      expect { do_post }.to change(Event, :count).by(1)
    end

    it 'sets the eventable' do
      expect { do_post }.to change { Event.find_by(eventable_id: move.id, eventable_type: 'Move') }.from(nil).to(be_a(Event))
    end

    it 'returns serialized data' do
      do_post

      event = Event.last
      resource_to_json = JSON.parse(ActionController::Base.render(json: event, serializer: EventSerializer))

      expect(response_json).to eq resource_to_json
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
      let(:event_attributes) { attributes_for(:event).merge(event_type: 'Event::FooBar') }

      let(:errors_422) do
        [
          {
            "title": 'Invalid event_type',
            "detail": 'Validation failed: Event type is not included in the list',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end
  end

  def do_post
    post '/api/events', params: { data: data }, headers: headers, as: :json
  end
end
