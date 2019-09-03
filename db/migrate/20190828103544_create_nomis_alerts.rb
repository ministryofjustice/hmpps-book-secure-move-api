class CreateNomisAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :nomis_alerts, id: :uuid do |t|
      t.string :type_code, null: false
      t.string :code, null: false
      t.string :description, null: false
      t.string :type_description, null: false
      t.uuid :assessment_question_id
      t.timestamps
    end
  end
end
