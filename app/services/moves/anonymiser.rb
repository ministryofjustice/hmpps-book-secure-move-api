# frozen_string_literal: true

module Moves
  class Anonymiser
    attr_accessor :move

    def initialize(move:)
      self.move = move
    end

    def call
      nomis_offender_number =
        People::Anonymiser.encrypt_offender_number(offender_number: move['offenderNo'])
      start_date_time = move['startTime'].present? ? Time.parse(move['startTime']) : nil
      start_time = start_date_time&.strftime('%H:%M:%S') || '00:00:00'

      move.merge(
        person_nomis_prison_number: nomis_offender_number,
        date: "<%= date.toISOString().split('T')[0] %>",
        time_due: "<%= date.toISOString().split('T')[0] + 'T' + '#{start_time}' %>",
      ).with_indifferent_access
    end
  end
end
