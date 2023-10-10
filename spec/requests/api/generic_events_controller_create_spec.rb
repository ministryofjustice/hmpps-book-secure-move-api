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
      'X-Current-User' => 'TEST_USER',
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
          'errors' => [{ 'detail' => "Couldn't find Location without an ID", 'title' => 'Resource not found' }],
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

    context 'when the event has no additional relationships' do
      let(:event_attributes) do
        {
          occurred_at: '2020-11-04T14:25:48+00:00',
          created_by: 'TEST_USER',
          recorded_at: '2020-11-04T14:25:48+00:00',
          notes: 'Flibble',
          details: {
            cancellation_reason: 'made_in_error',
            cancellation_reason_comment: 'It was a mistake',
          },
          event_type: 'MoveCancel',
        }
      end

      let(:data) do
        {
          type: 'events',
          attributes: event_attributes,
          relationships: {
            eventable: { data: { type: 'moves', id: move.id } },
          },
        }
      end

      it 'returns serialized data' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expect(response_json).to eq resource_to_json
      end

      it 'returns the serialized relationships of the event' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expected_relationships = {
          'eventable' => { 'data' => { 'id' => event.eventable.id, 'type' => 'moves' } },
          'supplier' => { 'data' => nil },
        }

        expect(resource_to_json.dig('data', 'relationships')).to eq(expected_relationships)
      end
    end

    context 'when the event has an additional relationship with no v2 implementation' do
      let(:event_attributes) do
        {
          occurred_at: '2020-11-04T14:31:51+00:00',
          created_by: 'TEST_USER',
          recorded_at: '2020-11-04T14:31:51+00:00',
          notes: 'Flibble',
          details: {
            reason: 'no_space',
            authorised_at: '2020-11-04T14:31:51+00:00',
            authorised_by: 'PMU',
          },
          event_type: 'MoveLockout',
        }
      end

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

      it 'returns serialized data' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expect(response_json).to eq resource_to_json
      end

      it 'returns the serialized from_location of the event' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expected_relationships = {
          'eventable' => { 'data' => { 'id' => event.eventable.id, 'type' => 'moves' } },
          'from_location' => { 'data' => { 'id' => event.from_location.id, 'type' => 'locations' } },
          'supplier' => { 'data' => nil },
        }
        expect(resource_to_json.dig('data', 'relationships')).to eq(expected_relationships)
      end

      it 'excludes the from_location from the details in the response' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expected_details = { 'authorised_at' => event.authorised_at, 'authorised_by' => 'PMU', 'reason' => 'no_space' }
        expect(resource_to_json.dig('data', 'attributes', 'details')).to eq(expected_details)
      end
    end

    context 'when the event has an additional relationship with a v2 implementation' do
      before do
        allow(V2::MoveSerializer).to receive(:new).and_call_original
      end

      let(:previous_move) { create(:move) }

      let(:event_attributes) do
        {
          occurred_at: '2020-11-04T14:31:51+00:00',
          recorded_at: '2020-11-04T14:31:51+00:00',
          created_by: 'TEST_USER',
          notes: 'Flibble',
          event_type: 'MoveCrossSupplierPickUp',
        }
      end

      let(:data) do
        {
          type: 'events',
          attributes: event_attributes,
          relationships: {
            eventable: { data: { type: 'moves', id: move.id } },
            previous_move: { data: { type: 'moves', id: previous_move.id } },
          },
        }
      end

      it 'returns serialized data' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expect(response_json).to eq resource_to_json
      end

      it 'returns the serialized previous_move of the event' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expected_relationships = {
          'eventable' => { 'data' => { 'id' => event.eventable.id, 'type' => 'moves' } },
          'previous_move' => { 'data' => { 'id' => event.previous_move.id, 'type' => 'moves' } },
          'supplier' => { 'data' => nil },
        }
        expect(resource_to_json.dig('data', 'relationships')).to eq(expected_relationships)
      end

      it 'excludes the previous_move from the details in the response' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expected_details = {}
        expect(resource_to_json.dig('data', 'attributes', 'details')).to eq(expected_details)
      end
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
      let(:access_token) { create(:access_token, application:).token }

      it 'sets the supplier_id' do
        do_post
        event = GenericEvent.find(response_json.dig('data', 'id'))
        expect(event.supplier).to eq(supplier)
      end

      it 'returns the supplier of the event in the relationships' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)

        expected_relationships = {
          'eventable' => { 'data' => { 'id' => event.eventable.id, 'type' => 'moves' } },
          'from_location' => { 'data' => { 'id' => event.from_location.id, 'type' => 'locations' } },
          'supplier' => { 'data' => { 'id' => event.supplier.id, 'type' => 'suppliers' } },
        }
        expect(resource_to_json.dig('data', 'relationships')).to eq(expected_relationships)
      end

      it 'returns the created_by of the event' do
        do_post

        event = GenericEvent.last
        resource_to_json = JSON.parse(event.class.serializer.new(event).serializable_hash.to_json)
        expect(resource_to_json.dig('data', 'attributes', 'created_by')).to eq('TEST_USER')
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
            from_location: { data: { type: 'locations', id: move.from_location.id } },
          },
        }
      end
      let(:errors_422) do
        [
          {
            'title' => 'Invalid event_type, eventable_type',
            'detail' => "Validation failed: Event type can't be blank, Event type '' is not a valid event_type, Eventable type 'movess' is not a valid eventable type",
          },
        ]
      end

      let(:event_attributes) { attributes_for(:generic_event).merge(type: 'Event::FooBar') }

      it_behaves_like 'an endpoint that responds with error 422' do
        before { do_post }
      end
    end
  end

  def do_post
    post '/api/events', params: { data: }, headers:, as: :json
  end
end
