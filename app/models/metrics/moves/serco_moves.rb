module Metrics
  module Moves
    module SercoMoves
      MOVES_SERCO_DATABASE = 'moves_serco'.freeze
      SERCO_KEY = 'serco'.freeze

      def serco
        @serco ||= Supplier.find_by(key: SERCO_KEY)
      end

      def moves
        Move.where(supplier: serco)
      end

      def database
        MOVES_SERCO_DATABASE
      end
    end
  end
end
