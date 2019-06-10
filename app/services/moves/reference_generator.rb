# frozen_string_literal: true

module Moves
  class ReferenceGenerator
    def call
      PERMISSIBLE_CHARACTERS.sample(REFERENCE_LENGTH).join
    end

    REFERENCE_LENGTH = 8
    PERMISSIBLE_CHARACTERS = %i[A C E F H J K M N P R T U V W X Y 1 2 3 4 5 6 7 8 9].freeze
  end
end
