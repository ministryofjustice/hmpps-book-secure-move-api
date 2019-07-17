# frozen_string_literal: true

class NomisClient
  class Genders
    class << self
      def get
        attributes_for(
          NomisClient.get(
            '/reference-domains/domains/SEX',
            headers: { 'Page-Limit' => '1000' }
          ).parsed
        )
      end

      def attributes_for(nomis_data)
        nomis_data.reject { |item| item['activeFlag'] == 'N' }.map do |item|
          { key: item['code'], title: item['description'] }
        end
      end
    end
  end
end
