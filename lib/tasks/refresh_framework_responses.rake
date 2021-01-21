namespace :framework_responses do
  desc 'Populate assessmentable association on framework_responses'
  task refresh_data: :environment do
    FrameworkResponse.update_all("assessmentable_type = 'PersonEscortRecord', assessmentable_id = person_escort_record_id")
  end

  desc 'Populate value_type on framework_responses'
  task populate_value_type: :environment do
    # Updates the response value type in batches of 1000
    FrameworkResponse.where(value_type: nil).includes(:framework_question).in_batches.each do |response_batch|
      response_batch.each { |response| response.value_type = response.framework_question.response_type }
      FrameworkResponse.import(response_batch.to_a, validate: false, timestamps: false, all_or_none: true, on_duplicate_key_update: %i[value_type])
    end
  end

  desc 'Populate section on framework_responses'
  task populate_section: :environment do
    # Updates the response section in batches of 1000
    FrameworkResponse.where(section: nil).includes(:framework_question).in_batches.each do |response_batch|
      response_batch.each { |response| response.section = response.framework_question.section }
      FrameworkResponse.import(response_batch.to_a, validate: false, timestamps: false, all_or_none: true, on_duplicate_key_update: %i[section])
    end
  end
end
