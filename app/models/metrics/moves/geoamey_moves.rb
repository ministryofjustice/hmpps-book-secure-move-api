module Metrics
  module Moves
    module GeoameyMoves
      MOVES_GEOAMEY_DATABASE = 'moves_geoamey'.freeze
      GEOAMEY = Supplier.find_by(key: 'geoamey')

      def moves
        Move.where(supplier: GEOAMEY)
      end

      def database
        MOVES_GEOAMEY_DATABASE
      end
    end
  end
end
