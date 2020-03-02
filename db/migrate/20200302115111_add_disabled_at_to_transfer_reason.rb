class AddDisabledAtToTransferReason < ActiveRecord::Migration[5.2]
  def change
    change_table :prison_transfer_reasons do |t|
      t.datetime :disabled_at
    end
  end
end
