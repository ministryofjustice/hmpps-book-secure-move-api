# frozen_string_literal: true

module Moves
  class NomisSynchroniser
    attr_accessor :location, :date

    def initialize(location:, date:)
      self.location = location
      self.date = date
    end

    def call
      return unless nomis_agency_id && date && prison?

      moves = NomisClient::Moves.get(nomis_agency_id, date)
      Moves::Importer.new(moves).call
    end

    private

    def nomis_agency_id
      location&.nomis_agency_id
    end

    def prison?
      location&.prison?
    end
  end
end
