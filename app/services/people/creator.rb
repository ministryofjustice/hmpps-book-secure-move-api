# frozen_string_literal: true

module People
  class Creator
    attr_accessor :person_params

    def initialize(person_params)
      self.person_params = person_params
    end

    def call
      # TODO: Implement this
    end
  end
end
