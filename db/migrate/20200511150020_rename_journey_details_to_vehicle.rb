class RenameJourneyDetailsToVehicle < ActiveRecord::Migration[5.2]
  def change
    rename_column :journeys, :details, :vehicle
  end
end
