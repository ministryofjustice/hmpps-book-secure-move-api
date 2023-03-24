class CreateAccessLogs < ActiveRecord::Migration[6.1]
  # The largest text column available in all supported RDBMS is
  # 1024^3 - 1 bytes, roughly one gibibyte.  We specify a size
  # so that MySQL will use `longtext` instead of `text`.  Otherwise,
  # when serializing very large objects, `text` might not be big enough.
  TEXT_BYTES = 1_073_741_823
  def change
    create_table :access_logs, id: :uuid do |t|
      t.uuid :request_id
      t.uuid :idempotency_key
      t.datetime :timestamp
      t.string :whodunnit
      t.string :client
      t.string :verb
      t.string :code
      t.string :controller_name
      t.string :path
      t.string :params
      t.text :body, limit: TEXT_BYTES

      t.index :controller_name
      t.index :client
    end
  end
end
