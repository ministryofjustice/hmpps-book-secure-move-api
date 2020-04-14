class UpdateCourtHearings < ActiveRecord::Migration[5.2]
  def change
    rename_column :court_hearings, :nomis_case_number, :case_number
    change_column_null :court_hearings, :move_id, true
  end
end
