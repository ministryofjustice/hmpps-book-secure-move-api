# frozen_string_literal: true

module ProfileAttributeTypes
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      ProfileAttributeType.where(filter_params.slice(:user_type, :category))
    end
  end
end
