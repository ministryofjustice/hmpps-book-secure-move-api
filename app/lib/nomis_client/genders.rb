# frozen_string_literal: true

class NomisClient
  class Genders
    def get
      NomisClient.get(
        '/reference-domains/domains/SEX',
        headers: { 'Page-Limit' => '100' }
      ).parsed
    end
  end
end
