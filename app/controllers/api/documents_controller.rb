# frozen_string_literal: true

module Api
  class DocumentsController < ApiController
    prepend_before_action :set_restricted_request_content_type, only: :create

    def create
      document = Document.create!(document_attributes)
      render_json document, serializer: DocumentSerializer, status: :created
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      # A call to this action with an empty file raises an InvalidSignature exception and
      # and not a RecordInvalid one, this is the only way I found to have a behaviour that
      # is consistent: Document.create!(file: nil) raises a RecordInvalid exception and
      # responds with the right error json
      Document.create!(file: nil)
    end

  private

    def document_attributes
      document_params[:attributes].merge(documentable: profile)
    end

    def document_params
      params.require(:data).permit(attributes: %i[file]).to_h
    end

  protected

    def set_restricted_request_content_type
      @restricted_request_content_type = 'multipart/form-data'
    end

    def profile
      move_id = params[:move_id]

      if move_id
        Move.accessible_by(current_ability).find(move_id).profile
      end
    end
  end
end
