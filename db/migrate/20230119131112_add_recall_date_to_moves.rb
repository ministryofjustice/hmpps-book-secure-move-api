class AddRecallDateToMoves < ActiveRecord::Migration[6.1]
  def change
    add_column :moves, :recall_date, :date
  end
end
