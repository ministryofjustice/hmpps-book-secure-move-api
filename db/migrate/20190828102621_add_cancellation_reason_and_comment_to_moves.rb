class AddCancellationReasonAndCommentToMoves < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :cancellation_reason, :string
    add_column :moves, :cancellation_reason_comment, :text
  end
end
