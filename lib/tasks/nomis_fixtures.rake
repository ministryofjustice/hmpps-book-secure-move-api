# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :nomis_fixtures do
  NOMIS_AGENCY_IDS = %w[LEI].freeze

  def anonymise_move(move_response, _offender_number)
    move_response
  end

  def anonymise_person(person_response)
    person_response
  end

  def save_person_response(_anonymised_person_response)
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
          puts "Anonymising #{anonymised_person_response['offenderNo']}..."
          anonymise_move(anonymised_person_response['offenderNo'], move)
        end
      end
    end
  end
end
