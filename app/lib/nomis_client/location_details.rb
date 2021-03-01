# frozen_string_literal: true

module NomisClient
  class LocationDetails
    class << self
      def get
        attributes_for(
          NomisClient::Base.get('/agencies/prison',
                                headers: { 'Page-Limit' => '5000' }).parsed,
        )
      end

      def attributes_for(nomis_data)
        {}.tap do |details_hash|
          nomis_data.map do |item|
            details_hash[item['agencyId']] = {
              premise: item['premise'],
              locality: item['locality'],
              city: item['city'],
              country: item['country'],
              postcode: item['postCode'],
            }
          end
        end
      end
    end
  end
end
