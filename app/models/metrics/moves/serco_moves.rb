module Metrics
  module Moves
    module SercoMoves
      MOVES_SERCO_DATABASE = 'moves_serco'.freeze
      SERCO = Supplier.find_by(key: 'serco')

      def moves
        Move.where(supplier: SERCO)
      end

      def database
        MOVES_SERCO_DATABASE
      end
    end
  end
end
