# frozen_string_literal: true

module V2
  module People
    class Finder
      attr_reader :filter_params

      def initialize(filter_params)
        @filter_params = filter_params
      end

      def call
        apply_filters(Person)
      end

    private

      def split_params(name)
        filter_params[name]&.split(',')
      end

      def apply_filters(scope)
        scope = scope.includes(:profiles, :ethnicity, :gender)
        scope = apply_police_national_computer_filters(scope)
        scope = apply_criminal_records_office_filters(scope)
        scope = apply_prison_number_filters(scope)
        scope
      end

      def apply_police_national_computer_filters(scope)
        scope = scope.where(police_national_computer: split_params(:police_national_computer)) if filter_params.key?(:police_national_computer)
        scope
      end

      def apply_criminal_records_office_filters(scope)
        scope = scope.where(criminal_records_office: split_params(:criminal_records_office)) if filter_params.key?(:criminal_records_office)
        scope
      end

      def apply_prison_number_filters(scope)
        scope = scope.where(prison_number: split_params(:prison_number)) if filter_params.key?(:prison_number)
        scope
      end
    end
  end
end
