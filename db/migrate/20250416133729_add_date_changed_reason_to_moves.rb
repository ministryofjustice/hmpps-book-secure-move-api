class AddDateChangedReasonToMoves < ActiveRecord::Migration[8.0]
  def change
    add_column :moves, :date_changed_reason, :string
  end
end
