# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('post_event_responses.yaml', version: 'v2') }
  let(:supplier) { create(:supplier, name: 'serco') }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:runner) { instance_double('GenericEvents::Runner') }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  before do
    allow(GenericEvents::Runner).to receive(:new).with(an_instance_of(Move)).and_return(runner)
    allow(runner).to receive(:call)
  end

  describe 'POST /events' do
    let(:event_attributes) do
      attributes_for(:event_move_lockout).tap do |attributes|
        attributes.except!(:eventable)
        attributes[:event_type] = 'MoveLockout'
      end
    end

    let(:move) { create(:move) }

    let(:data) do
      {
        type: 'events',
        attributes: event_attributes,
        relationships: {
          eventable: { data: { type: 'moves', id: move.id } },
          from_location: { data: { type: 'locations', id: move.from_location.id } },
        },
      }
    end

    it_behaves_like 'an endpoint that responds with success 201' do
      before { do_post }
    end

    context 'when event-specific relationships are in the details attribute' do
      let(:data) do
        {
          type: 'events',
          attributes: event_attributes,
          relationships: { eventable: { data: { type: 'moves', id: move.id } } },
        }
      end

      let(:expected_error) do
        {
          'errors' => [
            {
              'title' => 'Unprocessable entity',
              'detail' => "From location id can't be blank",
              'source' => {
                'pointer' => '/data/attributes/from_location_id',
              },
              'code' => 'blank',
            },
            {
              'title' => 'Unprocessable entity',
              'detail' => 'From location id the location relationship you passed has an id that does not exist in our system. please use an existing from location',
              'source' => {
                'pointer' => '/data/attributes/from_location_id',
              },
              'code' => 'The location relationship you passed has an id that does not exist in our system. Please use an existing from_location',
            },
          ],
        }
      end

      it 'returns with an error' do
        do_post
        expect(response_json).to eq(expected_error)
      end
    end

    context 'when event-specific relationships are in the relationship attribute' do
      let(:event_attributes) do
        attributes_for(:event_move_lockout).tap do |attributes|
          attributes.except!(:eventable)
          attributes[:details] = attributes[:details].except(:from_location_id)
          attributes[:event_type] = 'MoveLockout'
        end
      end

      it 'sets up relationships correctly' do
        do_post
        event = GenericEvent::MoveLockout.find(response_json.dig('data', 'id'))
        expect(event.from_location).to be_a(Location)
      end
    end

    it 'creates a event' do
      expect { do_post }.to change(GenericEvent::MoveLockout, :count).by(1)
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

    it 'does not set the supplier_id' do
      do_post
      event = GenericEvent.find(response_json.dig('data', 'id'))
      expect(event.supplier).to be_nil
    end

    it 'invokes the GenericEvents::Runner service' do
      do_post
      expect(runner).to have_received(:call)
    end

    context 'when using a real access token' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }

      it 'sets the supplier_id' do
        do_post
        event = GenericEvent.find(response_json.dig('data', 'id'))
        expect(event.supplier).to eq(supplier)
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
            'detail' => "Validation failed: Occurred at can't be blank, Occurred at must be formatted as a valid ISO-8601 date-time, Recorded at can't be blank, Recorded at must be formatted as a valid ISO-8601 date-time, Event type 'Event::FooBar' is not a valid event_type, Eventable type 'movess' is not a valid eventable type",
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
