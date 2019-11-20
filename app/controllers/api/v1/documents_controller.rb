# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < ApiController
      def create
        document = Document.create!(document_attributes)
        render json: document, status: 201
      end

      private

      PERMITTED_DOCUMENT_PARAMS = [
        attributes: [:description, :document_type, file: %i[filename data content_type]]
      ].freeze

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
