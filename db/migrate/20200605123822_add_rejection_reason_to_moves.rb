class AddRejectionReasonToMoves < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :rejection_reason, :string
  end
end
