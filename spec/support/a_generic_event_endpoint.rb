RSpec.shared_examples 'a generic event endpoint' do |event_type|
  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => 'Bearer spoofed-token',
    }
  end

  let(:data) do
    {
      type: 'events',
      attributes: event_attributes,
      relationships: {
        eventable: { data: { type: eventable_type, id: eventable_id } },
      }.merge(event_specific_relationships),
    }
  end

  let(:event_attributes) do
    attributes_for(factory).tap do |attributes|
      attributes.except!(:eventable)
      attributes[:event_type] = event_type
      attributes[:details].keys.grep(/_id/).each do |relationship_key|
        attributes[:details].delete(relationship_key)
      end
    end
  end

  let(:event_specific_relationships) do
    attributes = attributes_for(factory)
    relationship_attributes = attributes[:details].slice(*attributes[:details].keys.grep(/_id/))

    relationship_attributes.each_with_object({}) do |(key, value), acc|
      named_relationship_key = key.to_s.sub('_id', '')
      acc[named_relationship_key] = {
        'data' => {
          'id' => value,
          'type' => 'locations',
        },
      }
    end
  end

  let(:factory) { "event_#{event_type.underscore}" }

  before do
    allow(Notifier).to receive(:prepare_notifications)
  end

  describe 'POST /events' do
    it "creates a GenericEvent::#{event_type}" do
      expect { do_post }.to change("GenericEvent::#{event_type}".constantize, :count).by(1)
    end

    context 'when authenticated as a supplier user' do
      before { create(:supplier) }

      it "doesn't send out notifications to suppliers" do
        expect(Notifier).not_to have_received(:prepare_notifications)
      end
    end

    context 'when authenticated as a non-supplier user' do
      it 'sends out notifications to suppliers' do
        do_post

        expect(Notifier).to have_received(:prepare_notifications).with(topic: anything, action_name: 'create_event')
      end
    end
  end

  def do_post
    post '/api/events', params: { data: }, headers:, as: :json
  end
end
