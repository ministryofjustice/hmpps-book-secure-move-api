class MoveAddDateFromTo < ActiveRecord::Migration[5.2]
  def change
    change_table :moves do |t|
      t.date :date_from
      t.date :date_to
    end
  end
end
