module Metrics
  module Moves
    MOVES = 'moves'.freeze
    MOVES_DATABASE = 'moves'.freeze

    def database
      if supplier.present?
        "#{MOVES_DATABASE}_#{supplier.key}"
      else
        MOVES_DATABASE
      end
    end

    def moves
      if supplier.present?
        Move.where(supplier:)
      else
        Move.all
      end
    end
  end
end
