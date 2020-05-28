class MoveEvent < Event
  # NB: this class exposes a few methods specific to moves to the Event model

  def from_location
    @from_location ||= Location.find(event_params&.dig(:relationships, :from_location, :data, :id))
  end

  def to_location
    @to_location ||= Location.find(event_params&.dig(:relationships, :to_location, :data, :id))
  end

  def cancellation_reason
    @cancellation_reason ||= event_params.dig(:attributes, :cancellation_reason)
  end

  def cancellation_reason_comment
    @cancellation_reason_comment ||= event_params.dig(:attributes, :cancellation_reason_comment)
  end
end
