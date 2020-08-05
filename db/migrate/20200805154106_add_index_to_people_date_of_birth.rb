class AddIndexToPeopleDateOfBirth < ActiveRecord::Migration[6.0]
  def change
    change_table :people do |t|
      t.index :date_of_birth
    end
  end
end
