class NullFieldsOnProfile < ActiveRecord::Migration[6.0]
  def up
    change_column :profiles, :last_name, :string, null: true
    change_column :profiles, :first_names, :string, null: true
  end

  def down
    change_column :profiles, :last_name, :string, default: '', null: false
    change_column :profiles, :first_names, :string, default: '', null: false
  end
end
