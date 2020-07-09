# frozen_string_literal: true

module Moves
  class MoveTypeValidator < ActiveModel::Validator
    attr_reader :record

    def validate(record)
      @record = record
      return if record.move_type.blank?

      # Apply more complex validation rules for specific move types
      validate_police_from_location if includes? %w[video_remand_hearing]
    end

  private

    def includes?(move_types)
      move_types.include?(record.move_type.to_s)
    end

    def human_move_type
      record.move_type.to_s.humanize(capitalize: false)
    end

    def validate_police_from_location
      record.errors.add(:from_location, "must be a police location for #{human_move_type}") unless record.from_location&.police?
    end
  end
end
