# frozen_string_literal: true

module NomisClient
  class Moves
    class << self
      def get(nomis_agency_ids, date, event_type)
        attributes_for(
          get_response(nomis_agency_ids: nomis_agency_ids, date: date, event_type: event_type),
          event_type
        ).map do |move|
          response(move)
        end
      end

      def get_response(nomis_agency_ids:, date:, event_type: :courtEvents)
        NomisClient::Base.get(
          "/movements/transfers?#{agency_id_params(nomis_agency_ids)}",
          params: { **date_params(date), **event_params(event_type) },
          headers: { 'Page-Limit' => '500' }
        ).parsed
      end

      private

      def agency_id_params(nomis_agency_ids)
        nomis_agency_ids.map { |id| "agencyId=#{CGI.escape(id)}" }.join('&')
      end

      def attributes_for(nomis_data, event_type)
        nomis_data[event_type.to_s].map do |item|
          {
            person_nomis_prison_number: item['offenderNo'],
            from_location_nomis_agency_id: item['fromAgency'],
            to_location_nomis_agency_id: item['toAgency'],
            date: item['eventDate'],
            time_due: item['startTime'],
            status: Move::NOMIS_STATUS_TYPES[item['eventStatus']],
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

      def response(move)
        if NomisClient::Base.test_mode?
          ::Moves::Anonymiser.new(move: move).call
        else
          move
        end
      end
    end
  end
end
