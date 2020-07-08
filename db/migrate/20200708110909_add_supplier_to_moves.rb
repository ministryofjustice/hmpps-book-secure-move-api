class AddSupplierToMoves < ActiveRecord::Migration[6.0]
  def change
    add_reference :moves, :supplier, type: :uuid, foreign_key: true, index: true
  end
end
