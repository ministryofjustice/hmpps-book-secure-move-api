# frozen_string_literal: true

module NomisClient
  class Locations
    class << self
      def get
        attributes_for(
          NomisClient::Base.get(
            '/agencies',
            headers: { 'Page-Limit' => '5000' }
          ).parsed
        )
      end

      def attributes_for(nomis_data)
        nomis_data.select { |item| Location::NOMIS_AGENCY_TYPES.key?(item['agencyType']) }.map do |item|
          {
            key: item['agencyId'].parameterize(separator: '_'),
            nomis_agency_id: item['agencyId'],
            title: item['description'],
            location_type: Location::NOMIS_AGENCY_TYPES[item['agencyType']]
          }
        end
      end
    end
  end
end
