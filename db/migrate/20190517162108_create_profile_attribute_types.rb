class CreateProfileAttributeTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :profile_attribute_types, id: :uuid do |t|
      t.string :description, null: false
      t.string :category, null: false
      t.string :user_type, null: false
      t.string :alert_type
      t.string :alert_code
      t.timestamps
    end
  end
end
