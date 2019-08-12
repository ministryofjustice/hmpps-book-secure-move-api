# frozen_string_literal: true

class NomisFaker
  PERMISSIBLE_CHARACTERS = %i[A C E F H J K M N P R T U V W X Y].freeze
  PERMISSIBLE_NUMBERS = %i[1 2 3 4 5 6 7 8 9].freeze
  ETHNICITIES = [
    'White: Eng./Welsh/Scot./N.Irish/British',
    'Mixed: White and Black Caribbean',
    'Other: Any other background',
    'White: Any other background',
    'Black/Black British: African',
    'Asian/Asian British: Pakistani',
    'Asian/Asian British: Bangladeshi',
    'Black/Black British: Caribbean',
    'Asian/Asian British: Indian',
    'Black/Black British: Any other Backgr\'nd'
  ].freeze
  BIRTH_COUNTRIES = [
    'England',
    'Viet Nam',
    'Poland',
    'Pakistan',
    'Slovakia (Slovak Republic)',
    'Greece',
    'Morocco',
    'Albania',
    'Hungary',
    'Scotland',
    'Sweden',
    'Australia',
    'Italy',
    'Romania'
  ].freeze
  RELIGIONS = [
    'Church of England (Anglican)',
    'No Religion',
    'Rastafarian',
    'Muslim',
    'Roman Catholic',
    'Christian',
    'Atheist',
    'Buddhist',
    'Pentecostal'
  ].freeze
  CONVICTION_STATUSES = %w[Convicted Remand].freeze
  IMPRISONMENT_STATUSES = %w[SENT03 JR ADIMP_ORA TRL LASPO_DR ALP MLP LIFE LR SEC38 LR_ORA FTR_ORA UNKNOWN].freeze
  MARITAL_STATUSES = [
    'Single-not married/in civil partnership',
    'Married or in civil partnership',
    'Prefer not to say'
  ].freeze

  def self.nomis_offender_number
    PERMISSIBLE_CHARACTERS.sample.to_s +
      PERMISSIBLE_NUMBERS.sample(4).join +
      PERMISSIBLE_CHARACTERS.sample(2).join
  end

  def self.pnc_number
    "#{PERMISSIBLE_NUMBERS.sample(2).join}/#{PERMISSIBLE_NUMBERS.sample(6).join}#{PERMISSIBLE_CHARACTERS.sample}"
  end

  def self.cro_number
    "#{PERMISSIBLE_NUMBERS.sample(5).join}/#{PERMISSIBLE_NUMBERS.sample(2).join}#{PERMISSIBLE_CHARACTERS.sample}"
  end

  def self.ethnicity
    ETHNICITIES.sample
  end

  def self.birth_country
    BIRTH_COUNTRIES.sample
  end

  def self.religion
    RELIGIONS.sample
  end

  def self.conviction_status
    CONVICTION_STATUSES.sample
  end

  def self.imprisonment_status
    IMPRISONMENT_STATUSES.sample
  end

  def self.marital_status
    MARITAL_STATUSES.sample
  end
end

# rubocop:disable Metrics/BlockLength
namespace :nomis_fixtures do
  NOMIS_AGENCY_IDS = %w[LEI].freeze

  def anonymise_move(move_response, _offender_number)
    move_response
  end

  def prisons
    Location.where(location_type: 'prison').all
  end

  def anonymise_person(person_response)
    latest_location = prisons.sample
    {
      offenderNo: NomisFaker.nomis_offender_number,
      firstName: Faker::Name.first_name,
      middleNames: Faker::Name.first_name,
      lastName: Faker::Name.last_name,
      dateOfBirth: Faker::Date.between(80.years.ago, 20.years.ago),
      gender: %w[Male Female].sample,
      sexCode: %w[M F].sample,
      nationalities: %w[British Irish Dutch American Japanese].sample,
      currentlyInPrison: %w[Y N].sample,
      latestBookingId: 1_234_567,
      latestLocationId: latest_location.nomis_agency_id,
      latestLocation: latest_location.title,
      internalLocation: 'ABC-D-1-23',
      pncNumber: NomisFaker.pnc_number,
      croNumber: NomisFaker.cro_number,
      ethnicity: NomisFaker.ethnicity,
      birthCountry: NomisFaker.birth_country,
      religion: NomisFaker.religion,
      convictedStatus: NomisFaker.conviction_status,
      imprisonmentStatus: NomisFaker.imprisonment_status,
      receptionDate: nil,
      maritalStatus: NomisFaker.marital_status
    }.with_indifferent_access
  end

  def save_person_response(anonymised_person_response)
    file_name = "#{Rails.root}/db/fixtures/nomis/person-#{anonymised_person_response[:offenderNo]}.json"
    File.open(file_name, 'w+') do |file|
      file.write(JSON.pretty_generate([anonymised_person_response], indent: '  '))
    end
  end

  desc 'create anonymised moves/people'
  task import_moves: :environment do
    date = DateTime.civil(2019, 7, 8, 12, 23, 45)
    NOMIS_AGENCY_IDS.each do |nomis_agency_id|
      moves_response = NomisClient::Moves.get(
        nomis_agency_ids: nomis_agency_id,
        date: date
      ).values.flatten
      moves_response.map do |move|
        real_offender_number = move['offenderNo']
        person_response = NomisClient::People.get(
          nomis_offender_number: real_offender_number
        )
        if person_response.empty?
          puts "Can't find person #{real_offender_number}"
        else
          anonymised_person_response = anonymise_person(person_response.first)
          save_person_response(anonymised_person_response)
          puts "Anonymising #{anonymised_person_response[:offenderNo]}..."
          pp anonymised_person_response
          anonymise_move(anonymised_person_response[:offenderNo], move)
        end
      end
    end
  end
end
