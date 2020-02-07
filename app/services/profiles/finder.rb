# frozen_string_literal: true

module Profiles
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      apply_filters(Profile.includes(:person, :ethnicity, :gender))
    end

  private

    def apply_filters(scope)
      apply_police_national_computer_filters(scope)
    end

    def apply_police_national_computer_filters(scope)
      return unless filter_params.key?(:police_national_computer)

      scope.where('profile_identifiers @> ?', police_national_computer)
    end

    def police_national_computer
      [{ identifier_type: 'police_national_computer', value: filter_params[:police_national_computer] }].to_json
    end
  end
end
