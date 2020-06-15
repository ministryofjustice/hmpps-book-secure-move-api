class MoveEvent < Event
  # NB: this class exposes a few methods specific to moves to the Event model

  def date
    @date ||= event_params.dig(:attributes, :date)
  end

  def rejection_reason
    @rejection_reason ||= event_params.dig(:attributes, :rejection_reason)
  end

  def cancellation_reason
    @cancellation_reason ||= event_params.dig(:attributes, :cancellation_reason)
  end

  def cancellation_reason_comment
    @cancellation_reason_comment ||= event_params.dig(:attributes, :cancellation_reason_comment)
  end
end
