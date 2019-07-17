# frozen_string_literal: true

class NomisClient
  class Genders
    class << self
      def get
        NomisClient.get(
          '/reference-domains/domains/SEX',
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end
    end
  end
end
