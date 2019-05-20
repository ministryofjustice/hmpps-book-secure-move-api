class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles, id: :uuid do |t|
      t.uuid :person_id, null: false
      t.string :surname, null: false
      t.string :forenames, null: false
      t.date :date_of_birth
      t.string :aliases, array: true, default: []
      t.uuid :gender_id
      t.uuid :ethnic_code_id
      t.uuid :nationality_id
      t.timestamps
    end

    add_foreign_key :profiles, :people, name: :profiles_person_id
  end
end
