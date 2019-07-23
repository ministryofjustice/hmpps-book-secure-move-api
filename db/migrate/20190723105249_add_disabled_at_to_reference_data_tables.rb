class AddDisabledAtToReferenceDataTables < ActiveRecord::Migration[5.2]
  def change
    add_column :genders, :disabled_at, :datetime
    Gender.where(visible: false).each do |gender|
      gender.update!(disabled_at: 1.day.ago)
    end
    remove_column :genders, :visible
    add_column :ethnicities, :disabled_at, :datetime
    add_column :assessment_questions, :disabled_at, :datetime
    add_column :locations, :disabled_at, :datetime
    add_column :nationalities, :disabled_at, :datetime
    add_column :identifier_types, :disabled_at, :datetime
  end
end
