class AddBodyToAccessLogs < ActiveRecord::Migration[6.1]

  # The largest text column available in all supported RDBMS is
  # 1024^3 - 1 bytes, roughly one gibibyte.  We specify a size
  # so that MySQL will use `longtext` instead of `text`.  Otherwise,
  # when serializing very large objects, `text` might not be big enough.
  TEXT_BYTES = 1_073_741_823
  def change
    add_column :access_logs, :body, :text, limit: TEXT_BYTES
  end
end
