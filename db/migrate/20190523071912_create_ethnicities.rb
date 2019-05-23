class CreateEthnicities < ActiveRecord::Migration[5.2]
  def change
    create_table :ethnicities, id: :uuid do |t|
      t.string :value, null: false
      t.string :description
      t.timestamps
    end
  end
end
