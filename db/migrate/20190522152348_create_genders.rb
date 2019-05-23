class CreateGenders < ActiveRecord::Migration[5.2]
  def change
    create_table :genders, id: :uuid do |t|
      t.string :title, null: false
      t.string :description
      t.timestamps
    end
  end
end
