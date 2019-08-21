# frozen_string_literal: true

require 'nomis/faker'

module NomisClient
  class People
    class << self
      def get(nomis_offender_number:)
        NomisClient::Base.get(
          "/prisoners/#{nomis_offender_number}",
          params: {},
          headers: { 'Page-Limit' => '1000' }
        ).parsed
      end
    end
  end
end
