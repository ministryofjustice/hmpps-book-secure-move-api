# frozen_string_literal: true

module Moves
  class NomisSynchroniser
    attr_accessor :locations, :date

    def initialize(locations:, date:)
      self.locations = locations || []
      self.date = date
    end

    def call
      return unless nomis_agency_ids.present? && date && prison?

      moves = NomisClient::Moves.get(nomis_agency_ids, date)
      Moves::Importer.new(moves).call
      Moves::Sweeper.new(location, date, moves).call
    end

    private

    def nomis_agency_ids
      locations.map(&:nomis_agency_id)
    end

    def prison?
      locations.any?(&:prison?)
    end
  end
end
