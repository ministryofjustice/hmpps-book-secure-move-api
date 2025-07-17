class DropNationalitiesTable < ActiveRecord::Migration[8.0]
 def change
   drop_table :nationalities do |t|
     t.string :title, null: false
     t.string :description
     t.datetime :created_at, precision: nil, null: false
     t.datetime :updated_at, precision: nil, null: false
     t.string :key, null: false
     t.datetime :disabled_at, precision: nil
   end
 end
end