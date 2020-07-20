class CreateFrameworkResponsesFlagsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :framework_responses, :flags, column_options: { type: :uuid } do |t|
      t.index :framework_response_id
      t.index :flag_id
    end
  end
end
