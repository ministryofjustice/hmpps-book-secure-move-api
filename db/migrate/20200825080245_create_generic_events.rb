class CreateGenericEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :generic_events, id: :uuid do |t|
      t.uuid :eventable_id, null: false     # polymorphic eventable/subject of the event
      t.string :eventable_type, null: false # polymorphic eventable/subject of the event
      t.string :type, null: false           # Default Single Table Inheritance field
      t.text :notes                         # Arbitrary and human readable notes
      t.string :created_by                  # Indicates the creator of the event (expected to be one of "serco", "geoamey", "unknown")
      t.jsonb :details                      # Details that vary for different types (STI types) of event

      # Indicates when the event was recorded to have occurred for the client (or at least as close as feasible to when the event is thought to have occurred). This is used to replay the events in the correct order allowing for messages to eventually be received all in the correct order. Until events are received in the correct order, it is possible that the state of the eventable to the point isn't valid. This is also used for reporting purposes. In reality it could be when the event was recorded, when it was sent _or_ when it occurred.
      t.datetime :occurred_at, null: false, index: true

      t.timestamps
      t.index %i[eventable_id eventable_type]
    end
  end
end
