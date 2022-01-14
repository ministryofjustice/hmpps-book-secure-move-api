# frozen_string_literal: true

module Api
  class SuppliersController < ApiController
    def locations
      paginate locations_from_supplier_moves, serializer: LocationSerializer, include: included_relationships
    end

  private

    def locations_from_supplier_moves
      supplier = Supplier.find(params[:supplier_id])

      Location.joins(:moves_from)
              .includes(:suppliers)
              .where(moves: { supplier_id: supplier.id })
              .order(key: :asc)
              .distinct
    end

    def supported_relationships
      LocationSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
