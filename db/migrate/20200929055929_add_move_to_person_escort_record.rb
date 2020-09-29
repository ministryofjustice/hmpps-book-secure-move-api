class AddMoveToPersonEscortRecord < ActiveRecord::Migration[6.0]
  def change
    add_reference :person_escort_records, :move, type: :uuid, index: true, foreign_key: true, null: true
  end
end
