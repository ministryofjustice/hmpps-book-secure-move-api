class SetMoveStatusDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_null :moves, :status, false
    change_column_default :moves, :status, 'requested'
  end
end
