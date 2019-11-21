# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < ApiController
      CONTENT_TYPE = 'multipart/form-data'

      def create
        document = Document.create!(document_attributes)
        render_document(document, 201)
      end

      private

      PERMITTED_DOCUMENT_PARAMS = [
        attributes: %i[description document_type file]
      ].freeze

      def document_params
        params.require(:data).permit(PERMITTED_DOCUMENT_PARAMS).to_h
      end

      def document_attributes
        document_params[:attributes].merge(
          move: Move.find(params.dig(:move_id))
        )
      end

      def render_document(document, status)
        render json: document, status: status
      end
    end
  end
end
