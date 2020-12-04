# frozen_string_literal: true

module Api
  module Reference
    class SuppliersController < ApiController
      def index
        suppliers = Supplier.all
        render_json suppliers, serializer: SupplierSerializer
      end

      def show
        supplier = find_supplier
        raise ::ActiveRecord::RecordNotFound, "Couldn't find Supplier with #{params[:id]}" if supplier.nil?

        render_json supplier, serializer: SupplierSerializer, status: :ok
      end

    private

      def find_supplier
        Supplier.find_by(key: params[:id])
      end
    end
  end
end
