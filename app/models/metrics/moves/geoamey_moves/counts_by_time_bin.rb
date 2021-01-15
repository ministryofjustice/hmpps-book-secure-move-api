module Metrics
  module Moves
    module GeoameyMoves
      class CountsByTimeBin < Moves::CountsByTimeBin
        include GeoameyMoves
      end
    end
  end
end
