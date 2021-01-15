module Metrics
  module Moves
    module GeoameyMoves
      class CountsByMoveType < Moves::CountsByMoveType
        include GeoameyMoves
      end
    end
  end
end
