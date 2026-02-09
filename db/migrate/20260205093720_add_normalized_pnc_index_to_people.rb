class AddNormalizedPncIndexToPeople < ActiveRecord::Migration[8.0]
  def change
    add_index :people,
              "regexp_replace(upper(police_national_computer), '[^0-9A-Z]', '', 'g')",
              name: "index_people_on_pnc_normalized"
  end
end
