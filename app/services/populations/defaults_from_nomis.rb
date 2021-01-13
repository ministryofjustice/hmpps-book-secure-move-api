# frozen_string_literal: true

module Populations
  class DefaultsFromNomis
    def self.call(location, date)
      nomis_agency_id = location.nomis_agency_id
      assigned_cells = NomisClient::Rollcount.get(nomis_agency_id, false)
      unassigned_cells = NomisClient::Rollcount.get(nomis_agency_id, true)
      movements = NomisClient::Movements.get(nomis_agency_id, date)

      return {} unless assigned_cells.present? && unassigned_cells.present? && movements.present?

      all_cells = [assigned_cells, unassigned_cells].flatten
      cell_total = all_cells.compact.sum { |cell| cell['currentlyInCell'].to_i }
      arrivals = movements['in'].to_i
      discharges = movements['out'].to_i

      {
        unlock: cell_total - arrivals + discharges,
        discharges: discharges,
      }
    end
  end
end
