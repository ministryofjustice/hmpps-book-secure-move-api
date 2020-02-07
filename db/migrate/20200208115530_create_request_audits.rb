class CreateRequestAudits < ActiveRecord::Migration[5.2]
  def change
    create_table :request_audits, id: :uuid do |t|
      t.bigint :application_id, null: false
      t.foreign_key :oauth_applications, column: :application_id
      t.string :request, null: false

      t.timestamps
    end

    create_table :response_audits, id: :uuid do |t|
      t.uuid :request_audit_id, null: false
      t.jsonb :response, null: false
      t.index :response, using: :gin
    end
  end
end
