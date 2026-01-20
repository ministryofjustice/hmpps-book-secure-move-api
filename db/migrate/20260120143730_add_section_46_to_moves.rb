class AddSectionFortySixPaceToMoves < ActiveRecord::Migration[8.0]
  def change
    add_column :moves, :section_46, :boolean
  end
end
