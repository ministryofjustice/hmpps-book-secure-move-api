module Metrics
  module Moves
    module GeoameyMoves
      MOVES_GEOAMEY_DATABASE = 'moves_geoamey'.freeze
      GEOAMEY_KEY = 'geoamey'.freeze

      def geoamey
        @geoamey ||= Supplier.find_by(key: GEOAMEY_KEY)
      end

      def moves
        Move.where(supplier: geoamey)
      end

      def database
        MOVES_GEOAMEY_DATABASE
      end
    end
  end
end
