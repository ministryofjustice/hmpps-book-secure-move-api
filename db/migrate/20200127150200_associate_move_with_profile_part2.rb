# frozen_string_literal: true

class AssociateMoveWithProfilePart2 < ActiveRecord::Migration[5.2]
  def up
    Move.find_each do |move|
      move.profile_id = Person.find_by!(id: move.person_id).latest_profile.id
      move.save!
    end

    change_column_null :moves, :profile_id, false
    add_foreign_key :moves, :profiles

    change_table :moves do |t|
      t.index [:from_location_id, :to_location_id, :profile_id, :date], name: "index_move_loc_profile_date", unique: true
    end
  end

  def down
    remove_foreign_key :moves, :profiles
    change_column_null :moves, :profile_id, true

    Move.find_each do |move|
      move.person_id = move.profile.person.id
      move.save!
    end
  end
end
