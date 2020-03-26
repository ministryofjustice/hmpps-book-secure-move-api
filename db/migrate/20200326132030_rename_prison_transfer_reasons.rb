class RenamePrisonTransferReasons < ActiveRecord::Migration[5.2]
  def up
    execute("UPDATE prison_transfer_reasons SET title='Contract Package Area (CPA)' WHERE key='cpa'")
    execute("UPDATE prison_transfer_reasons SET title='Indeterminate Sentence Prisoner (ISP) to open' WHERE key='isp_to_open'")
    execute("UPDATE prison_transfer_reasons SET title='Multi Agency Public Protection Arrangements (MAPPA)' WHERE key='mappa'")
    execute("UPDATE prison_transfer_reasons SET title='Youth Justice Board (YJB)' WHERE key='yjb'")
  end

  def down
    execute("UPDATE prison_transfer_reasons SET title='CPA' WHERE key='cpa'")
    execute("UPDATE prison_transfer_reasons SET title='ISP to open' WHERE key='isp_to_open'")
    execute("UPDATE prison_transfer_reasons SET title='MAPPA' WHERE key='mappa'")
    execute("UPDATE prison_transfer_reasons SET title='YJB' WHERE key='yjb'")
  end
end
