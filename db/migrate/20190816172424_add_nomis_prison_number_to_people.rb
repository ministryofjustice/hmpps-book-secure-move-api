class AddNomisPrisonNumberToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :nomis_prison_number, :string
  end
end
