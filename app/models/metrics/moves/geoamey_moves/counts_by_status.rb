module Metrics
  module Moves
    module GeoameyMoves
      class CountsByStatus < Moves::CountsByStatus
        include GeoameyMoves
      end
    end
  end
end
