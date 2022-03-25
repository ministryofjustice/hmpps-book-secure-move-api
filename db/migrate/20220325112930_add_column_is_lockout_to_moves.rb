class AddColumnIsLockoutToMoves < ActiveRecord::Migration[6.1]
  def change
    add_column :moves, :is_lockout, :boolean, default: false
  end
end
