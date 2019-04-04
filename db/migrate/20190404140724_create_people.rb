class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people, id: :uuid do |t|
      t.timestamps
    end

    add_foreign_key :moves, :people
  end
end
