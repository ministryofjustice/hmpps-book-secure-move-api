class MoveEvent < Event
  # NB: this class exposes a few methods specific to moves to the Event model

  def to_location
    @to_location ||= Location.find(event_params&.dig(:relationships, :to_location, :data, :id))
  end
end
