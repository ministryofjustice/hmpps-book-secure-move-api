class AddProfilesLatestNomisBookingId < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :latest_nomis_booking_id, :integer
  end
end
