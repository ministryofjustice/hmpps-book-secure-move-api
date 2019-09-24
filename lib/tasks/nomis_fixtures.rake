# frozen_string_literal: true

require 'nomis/faker'

# rubocop:disable Metrics/BlockLength
namespace :nomis_fixtures do
  NOMIS_AGENCY_IDS = %w[LEI PVI MRI].freeze

  def create_fixture_directory
    FileUtils.mkdir_p(NomisClient::Base::FIXTURE_DIRECTORY) unless File.directory?(NomisClient::Base::FIXTURE_DIRECTORY)
  end

  def save_alerts_response(anonymised_alerts_response, nomis_offender_number)
    create_fixture_directory
    file_name = "#{NomisClient::Base::FIXTURE_DIRECTORY}/alerts-#{nomis_offender_number}.json"
    File.open(file_name, 'w+') do |file|
      file.write(JSON.pretty_generate(anonymised_alerts_response, indent: '  '))
    end
  end

  def save_person_response(anonymised_person_response, nomis_offender_number)
    create_fixture_directory
    file_name = "#{NomisClient::Base::FIXTURE_DIRECTORY}/person-#{nomis_offender_number}.json"
    File.open(file_name, 'w+') do |file|
      file.write(JSON.pretty_generate([anonymised_person_response], indent: '  '))
    end
  end

  def save_moves_response(anonymised_moves_response, date, nomis_agency_id)
    create_fixture_directory
    file_name = "#{NomisClient::Base::FIXTURE_DIRECTORY}/moves-#{date}-#{nomis_agency_id}.json.ejs"
    File.open(file_name, 'w+') do |file|
      file.write(JSON.pretty_generate(anonymised_moves_response, indent: '  '))
    end
  end

  desc 'create anonymised moves/people'
  task import_moves: :environment do
    offender_numbers = {}
    NOMIS_AGENCY_IDS.each do |nomis_agency_id|
      moves_response = (1..5).each do |attempt|
        puts "Fetching moves for #{nomis_agency_id} on #{date.iso8601} (attempt #{attempt})..."
        NomisClient::Moves.get_response(
          nomis_agency_id: nomis_agency_id,
          date: date,
          event_type: :courtEvents
        )
        break
      rescue Faraday::TimeoutError
        puts 'timed out'
      end
      anonymised_moves_response = moves_response.transform_values do |moves|
        moves.map do |move|
          real_offender_number = move['offenderNo']
          person_response = NomisClient::People.get_response(
            nomis_offender_number: real_offender_number
          )
          if person_response.empty?
            puts "Can't find person #{real_offender_number}"
            nil
          else
            nomis_offender_number =
              if offender_numbers.key?(real_offender_number)
                offender_numbers[real_offender_number]
              else
                offender_numbers[real_offender_number] = Nomis::Faker.nomis_offender_number
              end
            anonymised_person_response = People::Anonymiser.new(nomis_offender_number: nomis_offender_number).call
            save_person_response(anonymised_person_response, nomis_offender_number)
            puts "Anonymising #{nomis_offender_number}..."

            alerts_response = NomisClient::Alerts.get_response(
              nomis_offender_number: real_offender_number
            ).parsed
            anonymised_alerts_response = Alerts::Anonymiser.new(
              nomis_offender_number: nomis_offender_number,
              alerts: alerts_response
            ).call
            save_alerts_response(anonymised_alerts_response, nomis_offender_number)

            Moves::Anonymiser.new(
              nomis_offender_number: nomis_offender_number,
              move: move
            ).call
          end
        end.compact
        save_moves_response(anonymised_moves_response, day_offset, nomis_agency_id)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
