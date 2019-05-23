class CreateNationalities < ActiveRecord::Migration[5.2]
  def change
    create_table :nationalities, id: :uuid do |t|
      t.string :title, null: false
      t.string :description
      t.timestamps
    end
  end
end
