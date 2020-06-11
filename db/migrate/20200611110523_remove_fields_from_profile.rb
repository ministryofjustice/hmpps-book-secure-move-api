class RemoveFieldsFromProfile < ActiveRecord::Migration[6.0]
  def change
    change_column :profiles, :last_name, :string, null: true
    change_column :profiles, :first_names, :string, null: true
    change_column :profiles, :date_of_birth, :datetime, null: true
    change_column :profiles, :aliases, :string, null: true
    change_column :profiles, :gender_id, :uuid, null: true
    change_column :profiles, :ethnicity_id, :uuid, null: true
    change_column :profiles, :nationality_id, :uuid, null: true
    change_column :profiles, :profile_identifiers, :jsonb, null: true
    change_column :profiles, :gender_additional_information, :string, null: true
    change_column :profiles, :latest_nomis_booking_id, :integer, null: true
  end
end
