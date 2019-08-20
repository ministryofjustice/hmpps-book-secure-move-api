class MakeMovesToLocationNullable < ActiveRecord::Migration[5.2]
  def change
    change_column :moves, :to_location_id, :uuid, null: true
  end
end
