# frozen_string_literal: true

class AssociateMoveWithProfilePart1 < ActiveRecord::Migration[5.2]
  def up
    change_table :moves do |t|
      t.uuid :profile_id
    end
  end

  def down
    remove_column :moves, :profile_id
  end
end
