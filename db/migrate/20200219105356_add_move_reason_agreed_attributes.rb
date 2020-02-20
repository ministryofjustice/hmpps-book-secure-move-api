class AddMoveReasonAgreedAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :reasons, id: :uuid do |t|
      t.string :key, null: false, index: true, unique: true
      t.string :title, null: false
    end

    change_table :moves do |t|
      t.references :reason, type: :uuid, null: true
      t.text :reason_comment, null: true
      t.boolean :agreed, default: false, null: true
      t.string :agreed_by, null: true
    end
  end
end
