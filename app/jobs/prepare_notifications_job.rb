class PrepareNotificationsJob < ApplicationJob
  queue_as :default

  # This job creates multiple notifications - one for each relevant subscription
  def perform(args)
    puts "Preparing Notifications with: #{args}"

    topic = args[:topic][:type].constantize.find(args[:topic][:id]) # topic could be a move or a person/profile
    action = args[:action] # either: create / update / destroy

    case topic.class
    when Move
      # Find the move's supplier(s)!
      topic.suppliers.each do |supplier|
        supplier.subscriptions.enabled.each do |subscription|
          id = SecureRandom.uuid
          event_type = get_event_type(action, topic)
          data = get_data(id, event_type, topic, time_stamp)
          time_stamp = Time.now.utc
          Notification.create!(id: id, subscription: subscription, topic: topic, event_type: event_type, time_stamp: time_stamp, data: data)
        end
      end

    else
      raise 'Unhandled topic type'
    end
  end

private

  def get_event_type(action, topic)
    event_type =
      case action
      when 'create'
        'created'
      when 'update'
        'updated'
      when 'destroy'
        'deleted'
      else
        raise("Unhandled action type: #{topic.class}")
      end
    event_type + '_' +
      case topic.class
      when Move
        'move'
      when Profile
        'person'
      else
        raise("Unhandled topic type: #{topic.class}")
      end
  end

  def get_data(id, event_type, _topic, time_stamp)
    # TODO: probably better to build a serializer that construct this here...
    {
      data: {
        id: id,
        type: 'notifications',
        attributes: {
          event_type: event_type,
          timestamp: time_stamp,
        },
        relationships: {
          foo: 'bar',
        },
      },
    }


    # Example payload from API specification
    # {
    #     "data": {
    #         "id": "41ded016-2931-41bf-9eb0-24aaa3d44849",
    #         "type": "notifications",
    #         "attributes": {
    #             "event_type": "move_booked",
    #             "timestamp": "2020-08-28T17:21:53Z"
    #         },
    #         "relationships": {
    #             "move": {
    #                 "data": {
    #                     "id": "9041cc33-7060-4eda-929e-fd161c01274a",
    #                     "type": "moves"
    #                 },
    #                 "links": {
    #                     "self": "https://pecs.example.com/api/v1/moves/9041cc33-7060-4eda-929e-fd161c01274a"
    #                 }
    #             }
    #         }
    #     }
    # }
  end
end
