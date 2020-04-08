class CreateCourtHearings < ActiveRecord::Migration[5.2]
  def change
    create_table :court_hearings, id: :uuid do |t|
      t.uuid :move_id, null: false
      t.datetime :start_time
      t.date :case_start_date
      t.string :court_type
      t.text :comments
      t.string :nomis_case_number
      t.integer :nomis_case_id
      t.integer :nomis_hearing_id
      t.boolean :saved_to_nomis, default: false

      t.timestamps
    end
  end
end
