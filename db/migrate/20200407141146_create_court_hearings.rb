class CreateCourtHearings < ActiveRecord::Migration[5.2]
  def change
    create_table :court_hearings, id: :uuid do |t|
      t.references :move, type: :uuid, index: true, foreign_key: true

      t.datetime :start_time, null: false
      t.date :case_start_date
      t.string :case_type
      t.text :comments
      t.string :nomis_case_number
      t.integer :nomis_case_id
      t.integer :nomis_hearing_id
      t.boolean :saved_to_nomis, default: false

      t.timestamps
    end
  end
end
