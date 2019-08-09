# frozen_string_literal: true

class NomisClient
  class People
    class << self
      def get(nomis_offender_number:)
        NomisClient.get(
          "/prisoners/#{nomis_offender_number}",
          params: {},
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end
    end
  end
end
