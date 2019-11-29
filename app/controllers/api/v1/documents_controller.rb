# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < ApiController
      prepend_before_action :set_force_content_type

      CONTENT_TYPE = 'multipart/form-data'

      def create
        document = Document.create!(document_attributes)
        render json: document, status: 201, content_type: ApiController::CONTENT_TYPE
      end

      def destroy
        document = Document.find(params[:id])
        document.destroy!
        render json: document, status: 200, content_type: ApiController::CONTENT_TYPE
      end

      private

      PERMITTED_DOCUMENT_PARAMS = [
        attributes: %i[file]
      ].freeze

      def document_params
        params.require(:data).permit(PERMITTED_DOCUMENT_PARAMS).to_h
      end

      def document_attributes
        document_params[:attributes].merge(
          move: Move.find(params.dig(:move_id))
        )
      end

      def set_force_content_type
        @force_content_type = true
      end
    end
  end
end
