class AddNomisAlertTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :nomis_alerts, id: :uuid do |t|
      t.string :nomis_alert_type, null: false
      t.string :nomis_alert_code, null: false
      t.string :description, null: false
      t.uuid :assessment_question_id
      t.timestamps
    end
  end
end
