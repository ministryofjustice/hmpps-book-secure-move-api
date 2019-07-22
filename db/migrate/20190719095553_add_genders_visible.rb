class AddGendersVisible < ActiveRecord::Migration[5.2]
  def change
    add_column :genders, :visible, :boolean, null: false, default: false
  end
end
