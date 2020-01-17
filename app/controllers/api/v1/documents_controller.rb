# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < ApiController
      prepend_before_action :set_restricted_request_content_type, only: :create

      def create
        document = Document.create!(document_attributes)
        render json: document, status: :created
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        # A call to this action with an empty file raises an InvalidSignature exception and
        # and not a RecordInvalid one, this is the only way I found to have a behaviour that
        # is consistent: Document.create!(file: nil) raises a RecordInvalid exception and
        # responds with the right error json
        Document.create!(file: nil)
      end

      def destroy
        document = Document.find(params[:id])
        document.destroy!
        render json: document, status: :ok
      end

    private

      PERMITTED_DOCUMENT_PARAMS = [
        attributes: %i[file],
      ].freeze

      def document_params
        params.require(:data).permit(PERMITTED_DOCUMENT_PARAMS).to_h
      end

      def document_attributes
        document_params[:attributes].merge(
          move: Move.find(params.dig(:move_id)),
        )
      end

    protected

      def set_restricted_request_content_type
        @restricted_request_content_type = 'multipart/form-data'
      end
    end
  end
end
