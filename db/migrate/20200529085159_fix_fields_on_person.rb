class FixFieldsOnPerson < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :last_synced_with_nomis, :datetime
    add_column :profiles, :last_synced_with_nomis, :datetime

    # This field will be used to populate latest profile information and
    # is relevant to the latest version of a profile, only
    remove_column :people, :latest_nomis_booking_id, :datetime
  end
end
