class CreateYouthRiskAssessments < ActiveRecord::Migration[6.0]
  def change
    create_table :youth_risk_assessments, id: :uuid do |t|
      t.references :framework, type: :uuid, null: false, index: true, foreign_key: true
      t.references :profile, type: :uuid, null: false, index: true, foreign_key: true
      t.references :move, type: :uuid, null: false, index: true, foreign_key: true
      t.references :prefill_source, type: :uuid, null: true, index: true
      t.string "status", null: false
      t.jsonb "nomis_sync_status", default: [], null: false
      t.datetime "confirmed_at"
      t.datetime "completed_at"

      t.timestamps
    end
  end
end
