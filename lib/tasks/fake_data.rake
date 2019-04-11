# frozen_string_literal: true

namespace :fake_data do
  desc 'create fake people'
  task create_people: :environment do
    50.times do
      person = Person.create!
      person.profiles << Profile.new(
        forenames: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        date_of_birth: Faker::Date.between(80.years.ago, 20.years.ago)
      )
    end
  end

  desc 'create fake prisons'
  task create_prisons: :environment do
    PRISON_NAMES.each do |label|
      Location.create!(
        label: label,
        location_type: :prison
      )
    end
  end

  desc 'create fake courts'
  task create_courts: :environment do
    TOWN_NAMES.each do |town|
      Location.create!(
        label: "#{town} #{%w[County Crown Magistrates].sample} Court",
        location_type: :court
      )
    end
  end

  desc 'create fake moves'
  task create_moves: :environment do
    people = Person.all
    prisons = Location.where(location_type: 'prison').all
    courts = Location.where(location_type: 'court').all
    500.times do
      date = Faker::Date.between(10.days.ago, 20.days.from_now)
      time = date.to_time
      time = time.change(hour: [9, 12, 14].sample)
      Move.create!(
        date: date,
        time_due: time,
        person: people.sample,
        from_location: prisons.sample,
        to_location: courts.sample,
        status: 'scheduled',
        move_type: :court
      )
    end
  end

  desc 'recreate all the fake data - CAUTION: this deletes all existing data'
  task recreate_all: :environment do
    if Rails.env.development?
      [Move, Location, Profile, Person].each(&:destroy_all)
      Rake::Task['fake_data:create_people'].invoke
      Rake::Task['fake_data:create_prisons'].invoke
      Rake::Task['fake_data:create_courts'].invoke
      Rake::Task['fake_data:create_moves'].invoke
    else
      puts 'you can only run this in the development environment'
    end
  end

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
    'Guildford'
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
    'HMYOI Aylesbury',
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
    'HMYOI Deerbolt',
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
    'HMYOI Feltham',
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
    'HMYOI Werrington',
    'HMP Wolds',
    'HMP Whitemoor',
    'HMP/YOI Wormwood Scrubs',
    'HMP Whatton',
    'HMP Onley',
    'HMP/YOI Wandsworth',
    'HMP Garth',
    'HMYOI Wetherby',
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
    'HMP Hewell Grange'
  ].freeze
end
