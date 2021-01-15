module Metrics
  module Moves
    module GeoameyMoves
      class CountsByMoveTypeStatus < Moves::CountsByMoveTypeStatus
        include GeoameyMoves
      end
    end
  end
end
