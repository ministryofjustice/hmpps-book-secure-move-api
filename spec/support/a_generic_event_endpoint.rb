RSpec.shared_examples 'a generic event endpoint' do |factory, event_type|
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
      },
    }
  end

  let(:event_attributes) do
    attributes_for(factory).tap do |attributes|
      attributes.except!(:eventable)
      attributes[:event_type] = event_type
    end
  end

  describe 'POST /events' do
    it "creates a GenericEvent::#{event_type}" do
      expect { do_post }.to change("GenericEvent::#{event_type}".constantize, :count).by(1)
    end
  end

  def do_post
    post '/api/events', params: { data: data }, headers: headers, as: :json
  end
end
