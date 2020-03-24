class ChangeDefaultValueForActiveStorage < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:active_storage_attachments, :id, from: "gen_random_uuid()", to: nil)
    change_column_default(:active_storage_blobs, :id, from: "gen_random_uuid()", to: nil)
  end
end
