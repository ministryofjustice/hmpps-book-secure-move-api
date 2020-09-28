class CreateFrameworkNomisCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :framework_nomis_codes, id: :uuid do |t|
      t.string :code_type, null: false
      t.string "code"
      t.boolean "fallback", default: false, null: false

      t.timestamps
    end
  end
end
