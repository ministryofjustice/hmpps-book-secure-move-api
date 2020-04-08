class ChangeMoveDateToAllowNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :moves, :date, true
  end
end
