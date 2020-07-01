class CreatePersonEscortRecord < ActiveRecord::Migration[6.0]
  def change
    create_table :person_escort_records, id: :uuid do |t|
      t.references :framework, type: :uuid, null: false, index: true, foreign_key: true
      t.string "state", null: false

      t.timestamps
    end
  end
end
