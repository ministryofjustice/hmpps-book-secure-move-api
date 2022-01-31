class AddDateToJourneys < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :date, :date
  end
end
