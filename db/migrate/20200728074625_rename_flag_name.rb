class RenameFlagName < ActiveRecord::Migration[6.0]
  def change
    rename_column :flags, :name, :title
  end
end
