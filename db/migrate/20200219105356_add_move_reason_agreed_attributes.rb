class AddMoveReasonAgreedAttributes < ActiveRecord::Migration[5.2]
  def change
    change_table :moves do |t|
      t.string :reason, null: true
      t.text :reason_comment, null: true
      t.boolean :agreed, default: false, null: true
      t.string :agreed_by, null: true
    end
  end
end
