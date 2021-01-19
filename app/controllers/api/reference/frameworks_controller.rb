# frozen_string_literal: true

module Api
  module Reference
    class FrameworksController < ApiController
      def index
        paginate Framework.versioned.all, serializer: FrameworksSerializer
      end

      def show
        render_json framework, serializer: FrameworksSerializer, include: included_relationships, status: :ok
      end

    private

      def framework
        Framework.includes(active_record_relationships).find(params[:id])
      end

      def supported_relationships
        if action_name == 'index'
          []
        else
          FrameworksSerializer::SUPPORTED_RELATIONSHIPS
        end
      end
    end
  end
end
