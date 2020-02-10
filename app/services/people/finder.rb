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
      scope = scope.joins(:profiles)

      if filter_params.key?(:police_national_computer)
        scope.where('profiles.profile_identifiers @> ?', police_national_computer.to_json)
      end

      if filter_params.key?(:nomis_offender_no)
        scope.where('profiles.nomis_offender_no @> ?', nomis_offender_no.to_json)
      end

      scope
    end

    def police_national_computer
      [{ identifier_type: 'police_national_computer', value: filter_params[:police_national_computer] }]
    end

    def nomis_offender_no
      [{ identifier_type: 'prison_number', value: filter_params[:nomis_offender_no] }]
    end
  end
end
