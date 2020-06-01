class FixFieldsOnPersonAgain < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :last_synced_with_nomis,  :datetime
    add_column    :people,   :latest_nomis_booking_id, :integer
  end
end
