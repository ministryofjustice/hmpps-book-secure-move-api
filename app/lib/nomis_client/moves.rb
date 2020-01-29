# frozen_string_literal: true

module NomisClient
  class Moves
    class << self
      MAX_POSSIBLE_MOVES_IN_ONE_DAY = 500

      def get(nomis_agency_ids, date, event_type)
        attributes_for(
          get_response(nomis_agency_ids: nomis_agency_ids, date: date, event_type: event_type),
          event_type,
        ).map do |move|
          move
        end
      end

      # set movements=true to get confirmed as well as planned movements
      def get_response(nomis_agency_ids:, date:, event_type: :courtEvents)
        url = "/movements/transfers?#{agency_id_params(nomis_agency_ids)}"
        params = { **date_params(date), **event_params(event_type) }.merge(movements: true)
        result = NomisClient::Base.get(
          url,
          params: params,
          headers: { 'Page-Limit' => '500' },
          ).parsed
        Rails.logger.info("[NomisClient::Moves].get #{url} #{params} returned #{result.size} moves")
        result
      end

    private

      # passing this as an array to 'params' results in agencyId[]=LEI&agencyId[]=BXI rather tha agencyId=LEI
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
            nomis_event_id: item['eventId'],
          }
        end
      end

      def date_params(date)
        { fromDateTime: date.to_s(:nomis), toDateTime: (date + 1).to_s(:nomis) }
      end

      def event_params(event_type)
        %i[courtEvents releaseEvents transferEvents].map { |event| [event, event == event_type] }.to_h
      end
    end
  end
end
