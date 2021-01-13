# frozen_string_literal: true

module NomisClient
  class Rollcount
    class << self
      def get(agency_id:, unassigned:)
        NomisClient::Base.get("/movements/rollcount/#{agency_id}?unassigned=#{unassigned}").parsed
      end
    end
  end
end
