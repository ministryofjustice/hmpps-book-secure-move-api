# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < ApplicationController
      def create
        document = Document.new(document_attributes)
        document.file.attach(document_attributes[:file])
        document.save
        render json: document, status: 201
      end

      private

      PERMITTED_DOCUMENT_PARAMS = [attributes: %i[description document_type file]].freeze

      def document_params
        params.require(:data).permit(PERMITTED_DOCUMENT_PARAMS).to_h
      end

      def document_attributes
        document_params[:attributes].merge(
          move: Move.find(params.dig(:move_id))
        )
      end
    end
  end
end
