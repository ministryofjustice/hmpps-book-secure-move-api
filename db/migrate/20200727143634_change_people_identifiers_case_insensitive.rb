class ChangePeopleIdentifiersCaseInsensitive < ActiveRecord::Migration[6.0]
  def up
    change_column :people, :nomis_prison_number, :citext
    change_column :people, :prison_number, :citext
    change_column :people, :criminal_records_office, :citext
    change_column :people, :police_national_computer, :citext
  end

  def down
    change_column :people, :nomis_prison_number, :text
    change_column :people, :prison_number, :text
    change_column :people, :criminal_records_office, :text
    change_column :people, :police_national_computer, :text
  end
end
