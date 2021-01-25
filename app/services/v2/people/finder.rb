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
        return if filter_params[name].blank?

        filter_params[name].split(',')
      end

      def apply_filters(scope)
        scope = scope.includes(:profiles, :ethnicity, :gender)
        %i[police_national_computer criminal_records_office prison_number].each do |param|
          scope = apply_filter(param, scope)
        end

        scope
      end

      def apply_filter(param, scope)
        scope = scope.where(param => split_params(param)) if filter_params.key?(param)
        scope
      end
    end
  end
end
