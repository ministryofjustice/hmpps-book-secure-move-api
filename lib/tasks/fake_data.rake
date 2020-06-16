# frozen_string_literal: true

require_relative 'fake_data/journeys'

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
  # rubocop:disable all
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

  desc 'create fake prisons'
  task create_prisons: :environment do
    puts 'create_prisons...'
    %w[serco geoamey].each do |supplier|
      Supplier.create!(key: supplier, name: supplier.titleize)
    end
    suppliers = Supplier.all
    PRISON_NAMES.each do |title|
      Location.create!(
        key: title.parameterize(separator: '_'),
        title: title,
        location_type: :prison,
        suppliers: [suppliers.sample],
      )
    end
  end

  desc 'create fake courts'
  task create_courts: :environment do
    puts 'create_courts...'
    TOWN_NAMES.each do |town|
      title = "#{town} #{%w[County Crown Magistrates].sample} Court"
      Location.create!(
        key: title.parameterize(separator: '_'),
        title: title,
        location_type: :court,
      )
    end
  end

  desc 'create assessment questions'
  task create_assessment_questions: :environment do
    puts 'create_assessment_questions...'
    ASSESSMENT_QUESTIONS.each do |attribute_values|
      AssessmentQuestion.create!(attribute_values)
    end
  end

  desc 'create genders'
  task create_genders: :environment do
    puts 'create_genders...'
    GENDERS.each do |gender|
      Gender.create!(key: gender.parameterize(separator: '_'), title: gender)
    end
  end

  desc 'create ethnicities'
  task create_ethnicities: :environment do
    puts 'create_ethnicities...'
    ETHNICITIES.each do |attributes|
      Ethnicity.create!(attributes)
    end
  end

  desc 'create fake moves'
  task create_moves: :environment do
    puts 'create_moves...'
    profiles = Profile.all
    prisons = Location.where(location_type: 'prison').all
    courts = Location.where(location_type: 'court').all
    file = StringIO.new(File.read('spec/fixtures/file-sample_100kB.doc'))
    1000.times do
      date = Faker::Date.between(from: 10.days.ago, to: 20.days.from_now)
      time = date.to_time
      time = time.change(hour: [9, 12, 14].sample)
      profile = profiles.sample
      from_location = prisons.sample
      to_location = courts.sample
      nomis_event_ids = []
      nomis_event_ids << (1_000_000..1_500_000).to_a.sample if rand(2).zero?
      next if Move.find_by(date: date, profile: profile, from_location: from_location, to_location: to_location)

      move = Move.create!(
        date: date,
        date_from: date,
        time_due: time,
        profile: profile,
        from_location: from_location,
        to_location: to_location,
        status: %w[proposed requested completed].sample,
        nomis_event_ids: nomis_event_ids,
      )

      document = Document.new(move: move)
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

  desc 'drop all the fake data - CAUTION: this deletes all existing data'
  task drop_all: :environment do
    puts 'drop_all...'
    if Rails.env.development? || Rails.env.test?
      [Allocation, Event, Journey, Move, Document, Location, Profile, Person, AssessmentQuestion, Ethnicity, Gender, IdentifierType, Supplier].each(&:destroy_all)
    else
      puts 'you can only run this in the development or test environments'
    end
  end

  desc 'recreate all the fake data - CAUTION: this deletes all existing data'
  task recreate_all: :environment do
    if Rails.env.development? || Rails.env.test?
      Rake::Task['fake_data:drop_all'].invoke
      Rake::Task['fake_data:create_ethnicities'].invoke
      Rake::Task['fake_data:create_genders'].invoke
      Rake::Task['fake_data:create_assessment_questions'].invoke
      Rake::Task['fake_data:create_people'].invoke
      Rake::Task['fake_data:create_prisons'].invoke
      Rake::Task['fake_data:create_courts'].invoke
      Rake::Task['fake_data:create_moves'].invoke
      Rake::Task['fake_data:create_allocations'].invoke
      Rake::Task['fake_data:create_journeys'].invoke
    else
      puts 'you can only run this in the development or test environments'
    end
  end

  ASSESSMENT_QUESTIONS = [
    { key: :violent, category: :risk, title: 'Violent' },
    { key: :escape, category: :risk, title: 'Escape' },
    { key: :hold_separately, category: :risk, title: 'Must be held separately' },
    { key: :self_harm, category: :risk, title: 'Self harm' },
    { key: :concealed_items, category: :risk, title: 'Concealed items' },
    { key: :other_risks, category: :risk, title: 'Any other risks' },
    { key: :special_diet_or_allergy, category: :health, title: 'Special diet or allergy' },
    { key: :health_issue, category: :health, title: 'Health issue' },
    { key: :medication, category: :health, title: 'Medication' },
    { key: :wheelchair, category: :health, title: 'Wheelchair user' },
    { key: :pregnant, category: :health, title: 'Pregnant' },
    { key: :other_health, category: :health, title: 'Any other requirements' },
    { key: :solicitor, category: :court, title: 'Solicitor or other legal representation' },
    { key: :interpreter, category: :court, title: 'Sign or other language interpreter' },
    { key: :other_court, category: :court, title: 'Any other information' },
  ].freeze

  GENDERS = %w[Female Male Trans].freeze

  ETHNICITIES = [
    { key: 'A1', title: 'Asian or Asian British (Indian)', description: 'A1 - Asian or Asian British (Indian)' },
    { key: 'A2', title: 'Asian or Asian British (Pakistani)', description: 'A2 - Asian or Asian British (Pakistani)' },
    { key: 'A3',
      title: 'Asian or Asian British (Bangladeshi)',
      description: 'A3 - Asian or Asian British (Bangladeshi)' },
    { key: 'A9', title: 'Asian or Asian British (Other)', description: 'A9 - Asian or Asian British (Other)' },
    { key: 'B1', title: 'Black (Caribbean)', description: 'B1 - Black (Caribbean)' },
    { key: 'B2', title: 'Black (African)', description: 'B2 - Black (African)' },
    { key: 'B9', title: 'Black (Other)', description: 'B9 - Black (Other)' },
    { key: 'M1', title: 'Mixed (White and Black Caribbean)', description: 'M1 - Mixed (White and Black Caribbean)' },
    { key: 'M2', title: 'Mixed (White and Black African)', description: 'M2 - Mixed (White and Black African)' },
    { key: 'M3', title: 'Mixed (White and Asian)', description: 'M3 - Mixed (White and Asian)' },
    { key: 'M9', title: 'Mixed (Any other mixed background)', description: 'M9 - Mixed (Any other mixed background)' },
    { key: 'O1', title: 'Chinese', description: 'O1 - Chinese' },
    { key: 'O9', title: 'Any other ethnic group', description: 'O9 - Any other ethnic group' },
    { key: 'W1', title: 'White (British)', description: 'W1 - White (British)' },
    { key: 'W2', title: 'White (Irish)', description: 'W2 - White (Irish)' },
    { key: 'W9', title: 'White (Any other White background)', description: 'W9 - White (Any other White background)' },
  ].freeze

  TOWN_NAMES = [
    'Bedford',
    'Luton',
    'Maidenhead',
    'Newbury',
    'Reading',
    'Windsor',
    'Bristol',
    'Cambridge',
    'Peterborough',
    'Macclesfield',
    'Warrington',
    'Bodmin',
    'Bude',
    'Newquay',
    'Penzance',
    'Darlington',
    'Durham',
    'Barrow in Furness',
    'Carlisle',
    'Chesterfield',
    'Derby',
    'Axminster',
    'Barnstaple',
    'Exeter',
    'Plymouth',
    'Torquay',
    'Weymouth',
    'Brighton',
    'Colchester',
    'Harlow',
    'Romford',
    'Cheltenham',
    'Croydon',
    'Kingston upon Thames',
    'Richmond',
    'Southall',
    'Wimbledon',
    'Manchester',
    'Oldham',
    'Basingstoke',
    'Southampton',
    'Watford',
    'Dover',
    'Maidstone',
    'Blackburn',
    'Burnley',
    'Preston',
    'Grantham',
    'Grimsby',
    'Liverpool',
    'Norwich',
    'Oxford',
    'Wantage',
    'Guildford',
  ].freeze

  PRISON_NAMES = [
    'HMP/YOI Holme House',
    'HMP/YOI Hindley',
    'HMP/YOI Parc',
    'HMP Kingston',
    'HMP/YOI Hull',
    'HMP Humber',
    'HMP/YOI Pentonville',
    'HMP/YOI High Down',
    'HMP Highpoint',
    'HMIRC Haslar',
    'HMP Haverigg',
    'HMP Holloway',
    'HMP/YOI Altcourse',
    'HMP/YOI Askham Grange',
    'HMP Acklington',
    'HMP/YOI Isis',
    'HMP Albany',
    'HMP/YOI Isle of Wight',
    'HMP/YOI Rochester',
    'HMP Reading',
    'HMP Ashfield',
    'HMP Ashwell',
    'HMP Rye Hill',
    'HMP Aylesbury',
    'HMP Ranby',
    'HMP/YOI Belmarsh',
    'HMP Risley',
    'HMP Buckley Hall',
    'HMP Blundeston',
    'HMP/YOI Bedford',
    'HMP Blantyre House',
    'HMP Brockhill',
    'HMP/YOI Bristol',
    'HMP Birmingham',
    'HMP/YOI Bullingdon',
    'HMP Bure',
    'HMP/YOI Send',
    'HMP/YOI Brinsford',
    'HMP Blakenhurst',
    'HMP Bullwood Hall',
    'HMP Stafford',
    'HMP/YOI Stoke Heath',
    'HMP/YOI Berwyn',
    'HMP Brixton',
    'HMP Stocken',
    'HMP/YOI Bronzefield',
    'HMP Swaleside',
    'HMP Shepton Mallet',
    'HMP/YOI Swinfen Hall',
    'HMP/YOI Styal',
    'HMP/YOI Chelmsford',
    'HMP/YOI Sudbury',
    'HMP Kirkham',
    'HMP/YOI Cardiff',
    'HMP/YOI Swansea',
    'HMP Camp Hill',
    'HMP Shrewsbury',
    'HMYOI Cookham Wood',
    'HMP Kennet',
    'HMP Coldingley',
    'HMP/YOI Kirklevington Grange',
    'HMP/YOI Thorn Cross',
    'HMP Castington',
    'HMP Channings Wood',
    'HMP Lancaster',
    'HMP Canterbury',
    'HMP Leicester',
    'HMP Leeds',
    'HMP Lancaster Farms',
    'HMP Lowdham Grange',
    'HMP Lindholme',
    'HMP/YOI Lincoln',
    'HMP Dartmoor',
    'HMP/YOI Thameside',
    'HMP Long Lartin',
    'HMP Latchmere House',
    'HMP/YOI Low Newton',
    'HMP Dovegate',
    'HMP Liverpool',
    'HMP/YOI Drake Hall',
    'HMP Littlehey',
    'HMP/YOI Durham',
    'HMP/YOI Doncaster',
    'HMP/YOI Lewes',
    'HMP Leyhill',
    'HMP Dorchester',
    'HMP/YOI Deerbolt',
    'HMIRC Dover',
    'HMP/YOI Downview',
    'HMP Usk and HMP/YOI Prescoed',
    'HMP/YOI Moorland',
    'HMIRC Morton Hall',
    'HMP Erlestoke',
    'HMP/YOI Standford Hill',
    'HMP/YOI Manchester',
    'HMP Maidstone',
    'HMP The Mount',
    'Medway STC',
    'HMP/YOI East Sutton Park',
    'HMIRC The Verne',
    'HMP Everthorpe',
    'HMP/YOI Eastwood Park',
    'HMP/YOI Exeter',
    'HMP/YOI Elmley',
    'HMP Edmunds Hill',
    'HMP/YOI New Hall',
    'HMP/YOI Forest Bank',
    'HMP Northumberland',
    'HMP Ford',
    'HMP/YOI Nottingham',
    'HMP Northallerton',
    'HMP/YOI Foston Hall',
    'HMP North Sea Camp',
    'HMP Frankland',
    'HMP/YOI Feltham',
    'HMP Full Sutton',
    'HMP/YOI Norwich',
    'HMP The Weare',
    'HMP Wellingborough',
    'HMP/YOI Winchester',
    'HMP Wakefield',
    'HMP Featherstone',
    'HMP Wealstun',
    'HMP/YOI Woodhill',
    'HMP/YOI Warren Hill',
    'HMP Wayland',
    'HMP/YOI Wymott',
    'HMP/YOI Werrington',
    'HMP Wolds',
    'HMP Whitemoor',
    'HMP/YOI Wormwood Scrubs',
    'HMP Whatton',
    'HMP Onley',
    'HMP/YOI Wandsworth',
    'HMP Garth',
    'HMP/YOI Wetherby',
    'HMP Gloucester',
    'HMP Guys Marsh',
    'HMP Grendon/Spring Hill',
    'HMP Oakwood',
    'HMP/YOI Glen Parva',
    'HMP Gartree',
    'HMP/YOI Peterborough',
    'HMP/YOI Portland',
    'HMP/YOI Hollesley Bay',
    'HMP Parkhurst',
    'HMP Huntercombe',
    'HMP/YOI Hatfield',
    'HMP/YOI Hewell',
    'HMP/YOI Preston',
    'HMP Hewell Grange',
  ].freeze
end
