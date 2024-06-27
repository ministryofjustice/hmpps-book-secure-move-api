# frozen_string_literal: true

module Populations
  class DefaultsFromNomis
    def self.call(location, date)
      nomis_agency_id = location.nomis_agency_id
      all_cells = NomisClient::Rollcount.get(agency_id: nomis_agency_id)
      movements = NomisClient::Movements.get(agency_id: nomis_agency_id, date:)
      discharges = NomisClient::Discharges.get(agency_id: nomis_agency_id, date:)

      return {} unless all_cells.present? && movements.present?

      cell_total = all_cells.totals.currentlyInCell
      arrivals = movements['in'].to_i
      discharges = discharges.length

      {
        unlock: cell_total - arrivals + discharges,
        discharges:,
      }
    end
  end
end
