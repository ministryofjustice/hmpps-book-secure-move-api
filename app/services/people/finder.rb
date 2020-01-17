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
      apply_police_national_computer_filters(scope)
    end

    def apply_police_national_computer_filters(scope)
      return unless filter_params.key?(:police_national_computer)

      scope = scope.joins(:profiles)
      scope.where('profiles.profile_identifiers @> ?', police_national_computer)
    end

    def police_national_computer
      [{ identifier_type: 'police_national_computer', value: filter_params[:police_national_computer] }].to_json
    end
  end
end
