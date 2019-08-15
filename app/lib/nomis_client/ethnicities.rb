# frozen_string_literal: true

module NomisClient
  class Ethnicities
    class << self
      def get
        attributes_for(
          NomisClient::Base.get(
            '/reference-domains/domains/ETHNICITY',
            headers: { 'Page-Limit' => '1000' }
          ).parsed
        )
      end

      def attributes_for(nomis_data)
        nomis_data.reject { |item| item['activeFlag'] == 'N' }.map do |item|
          { key: item['code']&.downcase, nomis_code: item['code'], title: item['description'] }
        end
      end
    end
  end
end
