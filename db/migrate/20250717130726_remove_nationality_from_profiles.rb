class RemoveNationalityFromProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_reference :profiles, :nationality, type: :uuid
  end
end
