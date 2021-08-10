# frozen_string_literal: true

require_relative 'fake_data/journeys'
require_relative 'fake_data/gps'
require_relative 'fake_data/incident_events'
require_relative 'fake_data/medical_events'
require_relative 'fake_data/notification_events'

namespace :fake_data do
  desc 'create fake people'
  task create_people: :environment do
    puts 'create_people...'
    ethnicities = Ethnicity.all.to_a
    genders = Gender.all.to_a
    50.times do
      person = Person.create!(
        first_names: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        date_of_birth: Faker::Date.between(from: 80.years.ago, to: 20.years.ago),
        ethnicity: ethnicities.sample,
        gender: genders.sample,
        criminal_records_office: criminal_records_office,
        prison_number: prison_number,
        police_national_computer: police_national_computer,
      )
      person.profiles << Profile.new(
        assessment_answers: fake_assessment_answers,
      )
    end
  end

  # rubocop:disable all
  ASSESSMENT_ANSWERS = [
    { category: :risk,
      title: 'Violent',
      comments: ['Karate black belt', 'Unstable temper', 'Assaulted prison officer'] },
    { category: :risk,
      title: 'Escape',
      comments: ['Large poster in cell', 'Climber', 'Former miner'] },
    { category: :risk,
      title: 'Must be held separately',
      comments: ['Threat to other prisoners', 'Infectious skin disorder', 'Incitement to riot'] },
    { category: :risk,
      title: 'Self harm',
      comments: ['Attempted suicide'] },
    { category: :risk,
      title: 'Concealed items',
      comments: ['Rock hammer found in cell', 'Penknife found in trouser pockets'] },
    { category: :risk,
      title: 'Any other risks',
      comments: ['Train spotter', ''] },
    { category: :health,
      title: 'Special diet or allergy',
      comments: ['Gluten allergy', 'Lactose intolerant', 'Vegan'] },
    { category: :health,
      title: 'Health issue',
      comments: ['Heart condition', 'Broken arm', 'Flu', 'Keeps complaining of headaches'] },
    { category: :health,
      title: 'Medication',
      comments: ['Anti-biotics taken three-times daily', 'Heart medication needed twice daily'] },
    { category: :health, title: 'Wheelchair user', comments: [''] },
    { category: :health, title: 'Pregnant', comments: [''] },
    { category: :health,
      title: 'Any other requirements',
      comments: ['Unable to use stairs', 'Claustophobic', 'Agrophobic'] },
    { category: :court,
      title: 'Solicitor or other legal representation',
      comments: [''] },
    { category: :court,
      title: 'Sign or other language interpreter',
      comments: ['Only speaks Welsh', 'Only speaks French or Spanish', 'Partially Deaf'] },
    { category: :court,
      title: 'Any other information',
      comments: ['Former prison officer'] },
  ].freeze

  def fake_assessment_answers
    ASSESSMENT_ANSWERS.sample(3).map do |assessment_answer|
      fake_assessment_answer(assessment_answer)
    end
  end

  def fake_assessment_answer(assessment_answer)
    assessment_question = AssessmentQuestion.where(
      category: assessment_answer[:category],
      title: assessment_answer[:title],
    ).first
    return [] unless assessment_question

    {
      title: assessment_question.title,
      assessment_question_id: assessment_question.id,
      comments: assessment_answer[:comments].sample,
    }
  end

  def prison_number
    sprintf('D%04dZZ', seq)
  end

  def police_national_computer
    sprintf('AB/%07d', seq)
  end

  def criminal_records_office
    sprintf('CRO/%05d', seq)
  end

  def seq
    Time.zone.now.to_i
  end

  def fake_complex_case_answers
    AllocationComplexCase.all.map do |complex_case|
      {
        allocation_complex_case_id: complex_case.id,
        title: complex_case.title,
        key: complex_case.key,
        answer: [true, false].sample,
      }
    end
  end
  # rubocop:enable all

  desc 'create fake moves'
  task create_moves: :environment do
    puts 'create_moves...'
    profiles = Profile.all
    prisons = Location.where(location_type: 'prison').all
    courts = Location.where(location_type: 'court').all
    file = StringIO.new(File.read('spec/fixtures/files/file-sample_100kB.doc'))
    1000.times do
      date = Faker::Date.between(from: 10.days.ago, to: 20.days.from_now)
      time = date.to_time
      time = time.change(hour: [9, 12, 14].sample)
      profile = profiles.sample
      from_location = prisons.sample
      to_location = courts.sample
      next if Move.find_by(date: date, profile: profile, from_location: from_location, to_location: to_location)

      Move.create!(
        date: date,
        date_from: date,
        time_due: time,
        profile: profile,
        from_location: from_location,
        to_location: to_location,
        status: %w[proposed requested booked in_transit completed].sample,
        supplier: Supplier.all.sample,
      )
      document = Document.new(documentable: profile)
      document.file.attach(io: file, filename: 'file-sample_100kB.doc')
      document.save!
    ensure
      file.rewind
    end
  end

  desc 'create fake allocations'
  task create_allocations: :environment do
    puts 'create_allocations...'
    prisons = Location.where(location_type: 'prison').all
    50.times do
      date = Faker::Date.between(from: 10.days.ago, to: 20.days.from_now)
      Allocation.create!(
        date: date,
        from_location: prisons.sample,
        to_location: prisons.sample,
        prisoner_category: Allocation.prisoner_categories.values.sample,
        sentence_length: Allocation.sentence_lengths.values.sample,
        moves_count: Faker::Number.non_zero_digit,
        complete_in_full: Faker::Boolean.boolean,
        complex_cases: fake_complex_case_answers,
      )
    end
  end

  desc 'create fake incident events'
  task create_incident_events: :environment do
    puts 'create_incident_events...'
    Move
        .where(status: %w[completed booked requested])
        .where.not(to_location_id: nil)
        .order(Arel.sql('RANDOM()'))
        .limit(1000)
        .find_each do |move|
      Tasks::FakeData::IncidentEvents.new(move).call
    end
  end

  desc 'create fake medical events'
  task create_medical_events: :environment do
    puts 'create_medical_events...'
    PersonEscortRecord
        .where.not(move_id: nil)
        .order(Arel.sql('RANDOM()'))
        .limit(100)
        .find_each do |per|
      Tasks::FakeData::MedicalEvents.new(per).call
    end
  end

  desc 'create fake notification events'
  task create_notification_events: :environment do
    puts 'create_notification_events...'
    Move
        .where(status: %w[booked requested in_transit completed])
        .where.not(to_location_id: nil)
        .order(Arel.sql('RANDOM()'))
        .limit(1000)
        .find_each do |move|
      Tasks::FakeData::NotificationEvents.new(move).call
    end
  end

  desc 'create fake journeys with associated events'
  task create_journeys: :environment do
    puts 'create_journeys...'
    Move
        .left_outer_joins(:journeys).where(journeys: { move_id: nil })
        .where(status: %w[completed booked requested])
        .find_each do |move|
      Tasks::FakeData::Journeys.new(move).call
    end
  end

  desc 'create fake prison location populations'
  task create_populations: :environment do
    puts 'create_populations...'
    Location.prison.find_each do |location|
      (10.days.ago.to_date..20.days.from_now.to_date).each do |date|
        Population.create!(
          date: date,
          location_id: location.id,
          operational_capacity: Faker::Number.between(from: 200, to: 500),
          usable_capacity: Faker::Number.between(from: 250, to: 450),
          unlock: Faker::Number.between(from: 300, to: 400),
          bedwatch: Faker::Number.between(from: 1, to: 10),
          overnights_in: Faker::Number.between(from: 1, to: 10),
          overnights_out: Faker::Number.between(from: 1, to: 10),
          out_of_area_courts: Faker::Number.between(from: 1, to: 10),
          discharges: Faker::Number.between(from: 1, to: 10),
          updated_by: Faker::Name.name,
        )
      end
    end
  end

  desc 'create fake GPS track'
  task :create_gps_track, [:id_or_ref] => :environment do |_, args|
    abort "Please specify a journey id or move reference, e.g. $ rake 'fake_data:create_gps_track[ABC1234X]'" if args[:id_or_ref].blank?

    journey = Journey.find_by(id: args[:id_or_ref])
    journey ||= Move.find_by(id: args[:id_or_ref])&.journeys&.first
    journey ||= Move.find_by(reference: args[:id_or_ref])&.journeys&.first

    abort "Could not find journey record with id or move reference: #{args[:id_or_ref]}" if journey.blank?

    Tasks::FakeData::GPS.new(journey).call
  end

  desc 'drop all the fake data - CAUTION: this deletes all existing transactional data'
  task drop_all: :environment do
    puts 'drop_all...'
    if Rails.env.development? || Rails.env.test?
      [
        Allocation,
        Event,
        Document,
        Journey,
        Move,
        Profile,
        Person,
        Population,
      ].each(&:destroy_all)
    else
      puts 'you can only run this in the development or test environments'
    end
  end

  desc 'create all the fake data - this adds fake transactional data'
  task create_all: :environment do
    if Rails.env.development? || Rails.env.test?
      Rake::Task['fake_data:create_people'].invoke
      Rake::Task['fake_data:create_moves'].invoke
      Rake::Task['fake_data:create_allocations'].invoke
      Rake::Task['fake_data:create_journeys'].invoke
      Rake::Task['fake_data:create_populations'].invoke
    else
      puts 'you can only run this in the development or test environments'
    end
  end

  desc 'recreate all the fake data - CAUTION: this deletes all existing transactional data'
  task recreate_all: :environment do
    if Rails.env.development? || Rails.env.test?
      Rake::Task['fake_data:drop_all'].invoke
      Rake::Task['fake_data:create_all'].invoke
    else
      puts 'you can only run this in the development or test environments'
    end
  end
end
