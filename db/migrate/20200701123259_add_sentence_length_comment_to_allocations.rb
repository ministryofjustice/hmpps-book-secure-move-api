class AddSentenceLengthCommentToAllocations < ActiveRecord::Migration[6.0]
  def change
    add_column :allocations, :sentence_length_comment, :text
  end
end
