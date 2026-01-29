class AddSectionFortySixPaceToMoves < ActiveRecord::Migration[8.0]
  def change
    add_column :moves, :section_forty_six, :boolean
  end
end
