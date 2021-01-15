module Metrics
  module Moves
    MOVES_DATABASE = 'moves'.freeze

    def database
      MOVES_DATABASE
    end

    def moves
      Move.all
    end
  end
end
