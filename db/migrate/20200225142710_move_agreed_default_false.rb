class MoveAgreedDefaultFalse < ActiveRecord::Migration[5.2]
  def up
    Move.update_all(move_agreed: false)
    change_column_default :moves, :move_agreed, false
    change_column_null :moves, :move_agreed, false
  end

  def down
    change_column_null :moves, :move_agreed, true
    change_column_default :moves, :move_agreed, nil
  end
end
