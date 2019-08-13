# frozen_string_literal: true

require 'nomis/faker'

# rubocop:disable Metrics/BlockLength
namespace :nomis_fixtures do
  NOMIS_AGENCY_IDS = %w[LEI PVI MRI].freeze

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
    date = DateTime.civil(2019, 7, 8)
    (0..4).each do |day_offset|
      moves_response = nil
      NOMIS_AGENCY_IDS.each do |nomis_agency_id|
        5.times do
          errors = 0
          begin
            puts "Fetching moves for #{nomis_agency_id} on #{date.iso8601} (attempt #{errors + 1})..."
            moves_response = NomisClient::Moves.get(
              nomis_agency_ids: nomis_agency_id,
              date: date + day_offset.days
            )
            break
          rescue Net::ReadTimeout
            puts 'timed out'
          end
        end
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
              anonymised_person_response = NomisClient::People.anonymise(person_response.first)
              save_person_response(anonymised_person_response)
              puts "Anonymising #{anonymised_person_response[:offenderNo]}..."
              NomisClient::Moves.anonymise(anonymised_person_response[:offenderNo], move)
            end
          end.compact
        end
        save_moves_response(anonymised_moves_response, date.to_date.iso8601, nomis_agency_id)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
