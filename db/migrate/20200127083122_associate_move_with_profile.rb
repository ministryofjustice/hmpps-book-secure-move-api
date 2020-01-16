# frozen_string_literal: true

class AssociateMoveWithProfile < ActiveRecord::Migration[5.2]
  def up
    change_table :moves do |t|
      t.uuid :profile_id
      t.index [:from_location_id, :to_location_id, :profile_id, :date], name: "index_move_loc_profile_date", unique: true
    end
    Move.find_each do |move|
      move.profile_id = Person.find_by!(id: move.person_id).latest_profile.id
      move.save!
    end
    change_column_null :moves, :profile_id, false
    remove_column :moves, :person_id
    add_foreign_key :moves, :profiles
  end

  def down
    change_table :moves do |t|
      t.uuid :person_id
      t.index [:from_location_id, :to_location_id, :person_id, :date], name: "index_on_move_uniqueness", unique: true
    end
    Move.find_each do |move|
      move.person_id = move.profile.person.id
      move.save!
    end
    change_column_null :moves, :person_id, false
    remove_column :moves, :profile_id
    add_foreign_key :moves, :people
  end
end
