# frozen_string_literal: true

class NomisClient
  class Ethnicities
    class << self
      def get
        NomisClient.get(
          '/reference-domains/domains/ETHNICITY',
          headers: { 'Page-Limit' => '100' }
        ).parsed
      end
    end
  end
end
