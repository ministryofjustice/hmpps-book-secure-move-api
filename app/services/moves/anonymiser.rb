# frozen_string_literal: true

module Moves
  class Anonymiser
    attr_accessor :nomis_offender_number, :day_offset, :move_response

    def initialize(nomis_offender_number:, day_offset:, move_response:)
      self.nomis_offender_number = nomis_offender_number
      self.day_offset = day_offset
      self.move_response = move_response
    end

    def call
      start_date_time = move_response['startTime'].present? ? Time.parse(move_response['startTime']) : nil
      start_time = start_date_time&.strftime('%H:%M:%S') || '00:00:00'

      move_response.merge(
        offenderNo: nomis_offender_number,
        judgeName: nil,
        commentText: nil,
        createDateTime: "<%= (Time.now + #{day_offset}.days)&.iso8601 %>",
        eventDate: "<%= (Time.now + #{day_offset}.days)&.strftime('%Y-%m-%d') %>",
        startTime: "<%= (Time.now + #{day_offset}.days)&.strftime('%Y-%m-%d') + 'T' + '#{start_time}' %>"
      ).with_indifferent_access
    end
  end
end
