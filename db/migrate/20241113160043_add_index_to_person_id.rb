class AddIndexToPersonId < ActiveRecord::Migration[7.1]
  def change
    add_index :profiles, :person_id
  end
end
