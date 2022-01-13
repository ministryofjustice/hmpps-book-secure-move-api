# frozen_string_literal: true

module Api
  class SuppliersController < ApiController
    def locations
      paginate locations_from_supplier_moves, serializer: LocationSerializer, include: included_relationships
    end

  private

    def locations_from_supplier_moves
      supplier = Supplier.find(params[:supplier_id])

      ids_from_moves = supplier.moves.select(:from_location_id)
      ids_from_supplier_locations = supplier.supplier_locations.effective_on(Time.zone.today).select(:location_id)

      Location.includes(:suppliers)
              .where(id: ids_from_moves)
              .or(Location.where(id: ids_from_supplier_locations))
              .order(key: :asc)
              .distinct
    end

    def supported_relationships
      LocationSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
