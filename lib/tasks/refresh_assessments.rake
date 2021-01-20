namespace :assessments do
  desc 'Populate section_progress on assessments'
  task populate_section_progress: :environment do
    PersonEscortRecord.where("section_progress = '[]'").in_batches.each do |batch|
      update_section_progress(batch, PersonEscortRecord)
    end

    YouthRiskAssessment.where("section_progress = '[]'").in_batches.each do |batch|
      update_section_progress(batch, YouthRiskAssessment)
    end
  end
end

def update_section_progress(batch, klass_name)
  batch.each { |assessment| assessment.section_progress = assessment.calculate_section_progress }
  klass_name.import(batch.to_a, validate: false, timestamps: false, all_or_none: true, on_duplicate_key_update: %i[section_progress])
end
