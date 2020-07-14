class AddEstateCommentToAllocations < ActiveRecord::Migration[6.0]
  def change
    add_column :allocations, :estate_comment, :text
  end
end
