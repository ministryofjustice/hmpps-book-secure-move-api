module Api
  module Reference
    class CategoriesController < ApiController
      def index
        render_json Category.order(:key), serializer: CategorySerializer, status: :ok
      end
    end
  end
end
