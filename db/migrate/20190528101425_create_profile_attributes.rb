class CreateProfileAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :profile_attributes, id: :uuid do |t|
      t.uuid :profile_id, null: false
      t.uuid :profile_attribute_type_id, null: false
      t.date :date
      t.date :expiry_date
      t.string :description, null: false
      t.string :comments
      t.timestamps
    end
  end
end
