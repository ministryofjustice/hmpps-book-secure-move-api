class MoveEvent < Event
  # NB: this class exposes a few methods specific to moves to the Event model

  def create_in_nomis?
    @create_in_nomis ||= option_selected?(:create_in_nomis)
  end

  def rebook?
    @rebook ||= option_selected?(:rebook)
  end

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

private

  def option_selected?(attribute_name)
    event_params.dig(:attributes, attribute_name).to_s == 'true'
  end
end
