class SplitWhodunnitFromVersions < ActiveRecord::Migration[6.0]
  def up
    execute('UPDATE versions SET supplier_id = whodunnit::uuid, whodunnit = null WHERE whodunnit IN (SELECT id::text FROM suppliers)')
  end

  def down
    execute('UPDATE versions SET whodunnit = supplier_id, supplier_id = null WHERE supplier_id IS NOT NULL')
  end
end
