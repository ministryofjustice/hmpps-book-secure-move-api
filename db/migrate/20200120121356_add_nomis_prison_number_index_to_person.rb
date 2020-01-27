class AddNomisPrisonNumberIndexToPerson < ActiveRecord::Migration[5.2]
  def change
    change_table :people do |t|
      # can't be unique because nomis_prison_number is often nil
      t.index :nomis_prison_number
    end
  end
end
