# frozen_string_literal: true

module People
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      apply_filters(Person)
    end

  private

    def apply_filters(scope)
      if filter_params.key?(:police_national_computer)
        scope = scope.where(police_national_computer: filter_params[:police_national_computer])
      end

      if filter_params.key?(:prison_number)
        scope = scope.where(prison_number: filter_params[:prison_number])
      end

      scope
    end
  end
end
