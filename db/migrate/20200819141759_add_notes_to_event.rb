class AddNotesToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :notes, :text
  end
end
