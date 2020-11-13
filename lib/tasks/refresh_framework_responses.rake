namespace :framework_responses do
  desc 'Populate assessmentable association on framework_responses'
  task refresh_data: :environment do
    FrameworkResponse.update_all("assessmentable_type = 'PersonEscortRecord', assessmentable_id = person_escort_record_id")
  end
end
