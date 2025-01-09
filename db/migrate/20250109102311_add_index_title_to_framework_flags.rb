class AddIndexTitleToFrameworkFlags < ActiveRecord::Migration[8.0]
  def change
    add_index :framework_flags, :title
  end
end
