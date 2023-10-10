# frozen_string_literal: true

module Moves
  class ReferenceGenerator
    def call
      loop do
        reference =
          PERMISSIBLE_CHARACTERS.sample(REFERENCE_PART1_LENGTH).join +
          PERMISSIBLE_NUMBERS.sample(REFERENCE_PART2_LENGTH).join +
          PERMISSIBLE_CHARACTERS.sample(REFERENCE_PART3_LENGTH).join
        break reference unless Move.where(reference:).exists?
      end
    end

    REFERENCE_PART1_LENGTH = 3
    REFERENCE_PART2_LENGTH = 4
    REFERENCE_PART3_LENGTH = 1
    PERMISSIBLE_CHARACTERS = %i[A C E F H J K M N P R T U V W X Y].freeze
    PERMISSIBLE_NUMBERS = %i[1 2 3 4 5 6 7 8 9].freeze
  end
end
