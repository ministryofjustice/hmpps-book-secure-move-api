# frozen_string_literal: true

module Api
  module V1
    module Reference
      class SuppliersController < ApiController
        def index
          suppliers = Supplier.all
          render json: suppliers
        end

        def show
          supplier = find_supplier
          raise ::ActiveRecord::RecordNotFound, "Couldn't find Supplier with #{params[:id]}" if supplier.nil?

          render json: supplier, status: 200
        end

        private

        def find_supplier
          if ::UUID.validate(params[:id])
            Supplier.find(params[:id])
          else
            Supplier.find_by(key: params[:id])
          end
        end
      end
    end
  end
end
