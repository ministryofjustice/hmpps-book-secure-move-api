class AddMovesAdditionalInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :moves, :additional_information, :string
  end
end
