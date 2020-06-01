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

      def apply_filters(scope)
        scope.where(filters)
      end

      def filters
        allowed_filters.map { |filter_name, value| [filter_name.to_sym, value&.split(',')] }.to_h
      end

      def allowed_filters
        filter_params.select { |filter| %i[police_national_computer criminal_records_office prison_number].include?(filter.to_sym) }
      end
    end
  end
end
