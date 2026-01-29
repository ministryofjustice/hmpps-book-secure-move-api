# frozen_string_literal: true

require 'csv'

module Moves
  class Exporter
    attr_reader :alert_columns, :moves

    STATIC_HEADINGS = [
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
      'PACE S46',
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
      'Sign or other language interpreter',
      'Sign or other language interpreter details',
      'Not to be released',
      'Not to be released details',
      'Requires special vehicle',
      'Requires special vehicle details',
      'Cancelled at',
      'Cancelled by',
      'Cancellation reason',
      'cancellation reason comment',
      'Journey billable',
      'Difference',
      'Supplier',
    ].freeze

    def initialize(moves)
      @moves = moves
      @alert_columns = ENV.fetch('FEATURE_FLAG_CSV_ALERT_COLUMNS', 'false') == 'true'
    end

    def call
      Tempfile.new('export', Rails.root.join('tmp')).tap do |file|
        csv = CSV.new(file)
        headings = STATIC_HEADINGS
        headings += flags_by_section if alert_columns
        csv << headings
        moves.includes(active_record_associations).find_each do |move|
          csv << attributes_row(move)
        end
        file.flush
      end
    end

  private

    def active_record_associations
      associations = [:cancellation_events,
                      :journeys,
                      :from_location,
                      :to_location,
                      :profile,
                      :supplier,
                      { person: %i[ethnicity gender] }]

      if alert_columns
        associations += %i[
          person_escort_record youth_risk_assessment
        ]
      end

      associations
    end

    def attributes_row(move)
      person = move.person
      profile = move.profile
      answers = profile&.assessment_answers
      cancellation_event = move.cancellation_events.first

      row = [
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
        move.date&.strftime('%Y-%m-%d'), # Date of travel
        move.section_forty_six,
        person&.police_national_computer, # PNC number
        person&.prison_number, # Prison number
        person&.last_name, # Last name
        person&.first_names, # First name(s)
        person&.date_of_birth&.strftime('%Y-%m-%d'), # Date of birth
        person&.gender&.title, # Gender
        person&.ethnicity&.title, # Ethnicity
        person&.ethnicity&.key, # Ethnicity code
        answer_details(answers, 'violent'), # Violent details
        answer_details(answers, 'escape'), # Escape details
        answer_details(answers, 'hold_separately'), # Must be held separately details
        answer_details(answers, 'self_harm'), # Self harm details
        answer_details(answers, 'concealed_items'), # Concealed items details
        answer_details(answers, 'other_risks'), # Any other risks details
        answer_details(answers, 'health_issue'), # Health issue details
        answer_details(answers, 'medication'), # Medication details
        answer_details(answers, 'wheelchair'), # Wheelchair user details
        answer_details(answers, 'pregnant'), # Pregnant details
        answer_details(answers, 'other_health'), # Any other details
        answer_details(answers, 'interpreter'), # Sign or other language interpreter details
        answer_details(answers, 'not_to_be_released'), # Not to be released details
        answer_details(answers, 'special_vehicle'), # Requires special vehicle details,
        cancellation_event&.occurred_at, # Cancelled at
        cancellation_event&.created_by,
        move.cancellation_reason,
        move.cancellation_reason_comment,
        move.billable?,
        cancellation_difference(move, cancellation_event),
        move.supplier&.name,
      ]

      if alert_columns
        move_flags = []
        move_flags += Array(move.person_escort_record&.framework_flags&.pluck(:title))
        move_flags += Array(move.youth_risk_assessment&.framework_flags&.pluck(:title))
        row += flags_by_section.map { (move_flags&.include?(_1) ? 'TRUE' : '') }
      end

      row.flatten # Expand answer_details column pairs into individual columns
    end

    def answer_details(answers, key)
      selected_answers = answers&.select { |answer| answer.key == key }
      comments = selected_answers&.collect do |answer|
        description = answer.nomis_alert_description
        description.present? ? "#{description}: #{answer.comments}" : answer.comments
      end

      # Return the flag and comments together so we only need a single pass through the assessment answers for each key
      [comments.present?.to_s, comments&.join("\n\n")]
    end

    def flags_by_section
      @flags_by_section ||= FrameworkFlag
        .select('DISTINCT ON (title) *')
        .includes(:framework_question)
        .joins(:framework_question)
        .sort { |a, b|
          a.framework_question.section <=> b.framework_question.section
        }
        .pluck(:title)
    end

    def cancellation_difference(move, cancellation_event)
      return if !move.cancelled? || cancellation_event.blank?

      difference_in_seconds = (move.date.to_time.advance(hours: 6) - cancellation_event&.occurred_at)
      cutoff = "#{difference_in_seconds.positive? ? 'Before' : 'After'} cutoff"

      minutes = (difference_in_seconds.abs / 60).floor
      hours = (minutes / 60).floor

      "#{cutoff} (#{(hours / 24).floor}d "\
      "#{sprintf('%02d', hours % 24)}h "\
      "#{sprintf('%02d', minutes % 60)}m)"
    end
  end
end
