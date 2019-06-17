class RenameLocationDescription < ActiveRecord::Migration[5.2]
  def change
    rename_column :locations, :description, :title
  end
end
