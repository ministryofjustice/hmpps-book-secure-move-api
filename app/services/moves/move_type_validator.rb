# frozen_string_literal: true

module Moves
  class MoveTypeValidator < ActiveModel::Validator
    attr_reader :record

    def validate(record)
      @record = record
      return if record.move_type.blank?

      # Apply more complex validation rules for specific move types
      validate_court_to_location if includes? %w[court_appearance]
      validate_not_detained_to_location if includes? %w[court_other]
      validate_hospital_to_location if includes? %w[hospital]
      validate_police_to_location if includes? %w[police_transfer]
      validate_police_from_location if includes? %w[police_transfer prison_recall video_remand]
      validate_detained_to_location if includes? %w[prison_remand]
      validate_detained_from_location if includes? %w[prison_transfer]
    end

  private

    def includes?(move_types)
      move_types.include?(record.move_type.to_s)
    end

    def human_move_type
      record.move_type.to_s.humanize(capitalize: false)
    end

    def validate_court_to_location
      record.errors.add(:to_location, "must be a court location for #{human_move_type} move") unless record.to_location&.court?
    end

    def validate_detained_from_location
      record.errors.add(:from_location, "must be a prison, secure training centre or secure childrens hospital for #{human_move_type} move") unless record.from_location&.detained?
    end

    def validate_detained_to_location
      record.errors.add(:to_location, "must be a prison, secure training centre or secure childrens hospital for #{human_move_type} move") unless record.to_location&.detained?
    end

    def validate_hospital_to_location
      record.errors.add(:to_location, "must be a hospital or high security hospital location for #{human_move_type} move") unless record.to_location&.high_security_hospital? || record.to_location&.hospital?
    end

    def validate_not_detained_to_location
      record.errors.add(:to_location, "must not be a prison, secure training centre or secure childrens hospital for #{human_move_type} move") unless record.to_location&.not_detained?
    end

    def validate_police_from_location
      record.errors.add(:from_location, "must be a police location for #{human_move_type} move") unless record.from_location&.police?
    end

    def validate_police_to_location
      record.errors.add(:to_location, "must be a police location for #{human_move_type} move") unless record.to_location&.police?
    end
  end
end
