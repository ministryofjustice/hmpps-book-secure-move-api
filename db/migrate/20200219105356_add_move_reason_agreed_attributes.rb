class AddMoveReasonAgreedAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :prison_transfer_reasons, id: :uuid do |t|
      t.string :key, null: false, index: true, unique: true
      t.string :title, null: false
    end

    change_table :moves do |t|
      t.references :prison_transfer_reason, type: :uuid, null: true
      t.text :reason_comment, null: true
    end
  end
end
