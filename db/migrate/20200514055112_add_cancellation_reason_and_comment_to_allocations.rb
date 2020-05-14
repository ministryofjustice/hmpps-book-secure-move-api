class AddCancellationReasonAndCommentToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations, :cancellation_reason, :string
    add_column :allocations, :cancellation_reason_comment, :text
  end
end
