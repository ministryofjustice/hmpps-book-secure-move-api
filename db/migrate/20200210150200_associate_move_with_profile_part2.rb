# frozen_string_literal: true

class AssociateMoveWithProfilePart2 < ActiveRecord::Migration[5.2]
  def up
    Move.find_each.reject { |m| m.profile_id.present? }.each do |move|
      move.profile_id = Person.find_by!(id: move.person_id).latest_profile.id
      move.save!
    end

    change_column_null :moves, :profile_id, false
    add_foreign_key :moves, :profiles

    # person_id is unused after this migration, so it has to be nullable
    change_column_null(:moves, :person_id, true)
    remove_foreign_key :moves, :people
    # old unique index has to be removed now person_id is unused
    remove_index :moves, name: "index_on_move_uniqueness"
  end

  def down
    remove_foreign_key :moves, :profiles
    change_column_null :moves, :profile_id, true

    Move.find_each do |move|
      move.person_id = move.profile.person.id
      move.save!
    end

    change_column_null(:moves, :person_id, false)
    add_foreign_key :moves, :people
  end
end
