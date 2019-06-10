class GenerateReferences < ActiveRecord::Migration[5.2]
  def change
    Move.all.find_each do |move|
      move.update_attributes!(reference: Moves::ReferenceGenerator.new.call)
    end
    change_column :moves, :reference, :string, null: false
  end
end
