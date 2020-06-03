class ChangeNullMoveAgreed < ActiveRecord::Migration[5.2]
  def up
    change_column_null :moves, :move_agreed, true
    change_column_default :moves, :move_agreed, nil
  end

  def down
    Move.where(move_agreed: nil).update_all(move_agreed: false)
    change_column_default :moves, :move_agreed, false
    change_column_null :moves, :move_agreed, false
  end
end
