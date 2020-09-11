class AddGenericEventToEvent < ActiveRecord::Migration[6.0]
  def change
    # Adds a reference from event -> generic_event so we can know which event was copied
    # to which generic_event for debugging and rolling back (see https://dsdmoj.atlassian.net/browse/P4-2162).
    #
    # We'll also use this reference to know whether we've already copied the event across.
    add_reference :events, :generic_event, type: :uuid, foreign_key: true, index: true
  end
end
