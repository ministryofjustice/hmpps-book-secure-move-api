# frozen_string_literal: true

class ImportantEventsSerializer
  include JSONAPI::Serializer

  set_type :events

  attributes :event_type, :classification
end
