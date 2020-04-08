class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events, id: :uuid do |t|
      t.references :move, type: :uuid, null: false, index: true, foreign_key: true
      # we should probably have a reference to the user who created the event - however that concept isn't yet in the API
      # NB: some events might not be created by suppliers, so probably not wise to have supplier as a foreign key here
      t.string :event_type, null: false
      t.jsonb :details
      t.datetime :client_timestamp, null: false, index: true # this is provided by the client or supplier
      t.timestamps # these are maintained by the system and are distinct from client_timestamp
    end
  end
end
