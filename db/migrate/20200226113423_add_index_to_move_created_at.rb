class AddIndexToMoveCreatedAt < ActiveRecord::Migration[5.2]
  def change
    change_table :moves do |t|
      t.index :created_at
      t.index :date
    end
  end
end
