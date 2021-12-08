class DropEvents < ActiveRecord::Migration[6.1]
  def up
    drop_table :events
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
