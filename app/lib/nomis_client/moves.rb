# frozen_string_literal: true

class NomisClient
  class Moves
    class << self
      def get(nomis_agency_id, date, event_type = :courtEvents)
        attributes_for(
          get_nomis_moves(nomis_agency_id, date, event_type),
          event_type
        )
      end

      private

      def get_nomis_moves(nomis_agency_id, date, event_type)
        NomisClient.get(
          '/movements/transfers',
          params: { agencyId: nomis_agency_id, **date_params(date), **event_params(event_type) },
          headers: { 'Page-Limit' => '500' }
        ).parsed
      end

      def attributes_for(nomis_data, event_type)
        nomis_data[event_type.to_s].map do |item|
          {
            person_nomis_prison_number: item['offenderNo'],
            from_location_nomis_agency_id: item['fromAgency'],
            to_location_nomis_agency_id: item['toAgency'],
            date: item['eventDate'],
            time_due: item['startTime'] ? item['startTime'].split('T').last : nil,
            nomis_event_id: item['eventId']
          }
        end
      end

      def date_params(date)
        { fromDateTime: date.to_s(:nomis), toDateTime: (date + 1).to_s(:nomis) }
      end

      def event_params(event_type)
        %i[courtEvents movements releaseEvents transferEvents].map { |event| [event, event == event_type] }.to_h
      end
    end
  end
end
