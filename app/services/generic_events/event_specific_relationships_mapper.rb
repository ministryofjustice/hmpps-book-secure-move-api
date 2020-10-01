module GenericEvents
  class EventSpecificRelationshipsMapper
    def initialize(event_relationships)
      @event_relationships = event_relationships.to_h.except('eventable')
    end

    def call
      @event_relationships.each_with_object({}) do |(relationship, relationship_attributes), acc|
        key = "#{relationship}_id"
        id = relationship_attributes.dig(:data, :id)

        acc[key] = id
      end
    end
  end
end
