# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :nomis_fixtures do
  NOMIS_AGENCY_IDS = %w[LEI].freeze

  def anonymise_move(offender_number, move_response)
    move_response.merge(
      offenderNo: offender_number,
      judgeName: nil,
      commentText: nil
    ).with_indifferent_access
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

  def save_moves_response(anonymised_moves_response, date, location)
    file_name = "#{Rails.root}/db/fixtures/nomis/moves-#{date}-#{location}.json"
    File.open(file_name, 'w+') do |file|
      file.write(JSON.pretty_generate(anonymised_moves_response, indent: '  '))
    end
  end

  desc 'create anonymised moves/people'
  task import_moves: :environment do
    date = DateTime.civil(2019, 7, 8, 12, 23, 45)
    NOMIS_AGENCY_IDS.each do |nomis_agency_id|
      moves_response = NomisClient::Moves.get(
        nomis_agency_ids: nomis_agency_id,
        date: date
      )
      anonymised_moves_response = moves_response.transform_values do |moves|
        moves.map do |move|
          real_offender_number = move['offenderNo']
          person_response = NomisClient::People.get(
            nomis_offender_number: real_offender_number
          )
          if person_response.empty?
            puts "Can't find person #{real_offender_number}"
            nil
          else
            anonymised_person_response = anonymise_person(person_response.first)
            save_person_response(anonymised_person_response)
            puts "Anonymising #{anonymised_person_response[:offenderNo]}..."
            anonymise_move(anonymised_person_response[:offenderNo], move)
          end
        end.compact
      end
      save_moves_response(anonymised_moves_response, date.to_date.iso8601, nomis_agency_id)
    end
  end
end
