class AddUniqueIndexOnPersonEscortRecord < ActiveRecord::Migration[6.0]
  def change
    remove_index :person_escort_records, :profile_id
    add_index :person_escort_records, :profile_id, unique: true
  end
end
