# frozen_string_literal: true

require 'csv'

module Moves
  class Exporter
    attr_reader :moves

    HEADINGS = [
      'Status',
      'Reference',
      'Move type',
      'Created at',
      'Last updated',
      'From location name',
      'From location code',
      'To location name',
      'To location code',
      'Additional information',
      'Date of travel',
      'PNC number',
      'Prison number',
      'Last name',
      'First name(s)',
      'Date of birth',
      'Gender',
      'Ethnicity',
      'Ethnicity code',
      'Violent',
      'Violent details',
      'Escape',
      'Escape details',
      'Must be held separately',
      'Must be held separately details',
      'Self harm',
      'Self harm details',
      'Concealed items',
      'Concealed items details',
      'Any other risks',
      'Any other risks details',
      'Special diet or allergy',
      'Special diet or allergy details',
      'Health issue',
      'Health issue details',
      'Medication',
      'Medication details',
      'Wheelchair user',
      'Wheelchair user details',
      'Pregnant',
      'Pregnant details',
      'Any other requirements',
      'Any other requirements details',
      'Solicitor or other legal representation',
      'Solicitor or other legal representation details',
      'Sign or other language interpreter',
      'Sign or other language interpreter details',
      'Any other information',
      'Any other information details',
      'Not for release',
      'Not for release details',
      'Not to be released',
      'Not to be released details',
      'Requires special vehicle',
      'Requires special vehicle details',
      'Uploaded documents',
    ]

    MOVE_INCLUDES = [:from_location, :to_location, :profile, :documents, person: %i[gender ethnicity]].freeze

    def initialize(moves)
      @moves = moves
    end

    def call
      Tempfile.new('export', Rails.root.join('tmp')).tap do |file|
        csv = CSV.new(file)
        csv << HEADINGS
        moves.includes(MOVE_INCLUDES).find_in_batches do |batched_moves|
          batched_moves.each do |move|
            csv << attributes_row(move)
          end
        end
      end
    end

  private

    def attributes_row(move)
      person = move.person
      answers = move.profile&.assessment_answers

      [
        move.status, # Status
        move.reference, # Reference
        move.move_type, # Move type
        move.created_at.iso8601, # Created at
        move.updated_at.iso8601, # Last updated
        move.from_location&.title, # From location name
        move.from_location&.nomis_agency_id, # From location code
        move.to_location&.title, # To location name
        move.to_location&.nomis_agency_id, # To location code
        move.additional_information, # Additional information
        move.date&.strftime('%d/%m/%Y'), # Date of travel
        person&.police_national_computer, # PNC number
        person&.prison_number, # Prison number
        person&.last_name, # Last name
        person&.first_names, # First name(s)
        person&.date_of_birth&.strftime('%d/%m/%Y'), # Date of birth
        person&.gender&.title, # Gender
        person&.ethnicity&.title, # Ethnicity
        person&.ethnicity&.key, # Ethnicity code
        answer_details(answers, 'violent'), # Violent details
        answer_details(answers, 'escape'), # Escape details
        answer_details(answers, 'hold_separately'), # Must be held separately details
        answer_details(answers, 'self_harm'), # Self harm details
        answer_details(answers, 'concealed_items'), # Concealed items details
        answer_details(answers, 'other_risks'), # Any other risks details
        answer_details(answers, 'special_diet_or_allergy'), # Special diet or allergy details
        answer_details(answers, 'health_issue'), # Health issue details
        answer_details(answers, 'medication'), # Medication details
        answer_details(answers, 'wheelchair'), # Wheelchair user details
        answer_details(answers, 'pregnant'), # Pregnant details
        answer_details(answers, 'other_health'), # Any other details
        answer_details(answers, 'solicitor'), # Solicitor or other legal representation details
        answer_details(answers, 'interpreter'), # Sign or other language interpreter details
        answer_details(answers, 'other_court'), # Any other information details
        answer_details(answers, 'not_for_release'), # Not for release details
        answer_details(answers, 'not_to_be_released'), # Not to be released details
        answer_details(answers, 'special_vehicle'), # Requires special vehicle details
        move.documents.size, # 'Uploaded documents',
      ].flatten
    end

   def answer_details(answers, key)
      selected_answers = answers&.select { |answer| answer.key == key }
      comments = selected_answers&.collect do |answer|
        description = answer.nomis_alert_description
        description.present? ? "#{description}: #{answer.comments}" : answer.comments
      end

      [comments.present?.to_s.upcase, comments&.join("\n\n")]
    end
  end
end
