module Metrics
  module Moves
    module GeoameyMoves
      class CountsByStatus100Day < Moves::CountsByStatus100Day
        include GeoameyMoves
      end
    end
  end
end
