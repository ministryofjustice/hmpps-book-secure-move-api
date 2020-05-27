class AddsFieldsToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :prison_number, :string
    add_column :people, :criminal_records_office, :string
    add_column :people, :police_national_computer, :string

    add_column :people, :first_names, :string
    add_column :people, :last_name, :string
    add_column :people, :date_of_birth, :date
    add_column :people, :gender_additional_information, :string

    add_column :people, :latest_nomis_booking_id, :string

    add_reference :people, :ethnicity, type: :uuid
    add_reference :people, :gender, type: :uuid

    add_index :people, :prison_number
    add_index :people, :criminal_records_office
    add_index :people, :police_national_computer
  end
end
