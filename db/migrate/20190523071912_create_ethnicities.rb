class CreateEthnicities < ActiveRecord::Migration[5.2]
  def change
    create_table :ethnicities, id: :uuid do |t|
      t.string :code, null: false
      t.string :title, null: false
      t.string :description
      t.timestamps
    end
  end
end
