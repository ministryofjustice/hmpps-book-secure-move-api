# frozen_string_literal: true

module NomisClient
  class Rollcount
    class << self
      def get(agency_id:)
        NomisClient::Base.get("/prison/roll-count/#{agency_id}").parsed
      end
    end
  end
end
