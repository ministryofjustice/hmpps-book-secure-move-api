# frozen_string_literal: true

module Api
  class SuppliersController < ApiController
    def locations
      paginate locations_from_supplier_moves
    end

  private

    def locations_from_supplier_moves
      supplier = Supplier.find(params[:supplier_id])

      Location.joins(:moves_from).where(moves: { supplier_id: supplier.id }).distinct
    end
  end
end
