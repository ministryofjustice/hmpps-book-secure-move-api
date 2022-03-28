class AddIndexToJourneyDate < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :journeys, :date, algorithm: :concurrently
  end
end
