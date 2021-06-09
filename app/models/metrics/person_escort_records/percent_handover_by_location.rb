module Metrics
  module PersonEscortRecords
    class PercentHandoverByLocation
      include BaseMetric
      include PersonEscortRecords
      include ActionView::Helpers::NumberHelper

      attr_reader :reporting_date

      def initialize(supplier: nil)
        @reporting_date = ENV['REPORTING_DATE'].present? ? Date.parse(ENV['REPORTING_DATE']) : Date.yesterday

        setup_metric(
          supplier: supplier,
          label: 'PER handover by location',
          file: "#{reporting_date.year}/#{reporting_date.month}/#{reporting_date.day}/per_handover_by_location",
          interval: 6.hours,
          columns: {
            name: 'handovers',
            field: :itself,
            values: %w[location type number_of_PERs handover_percent],
          },
          rows: {
            name: 'agency_ID',
            field: :nomis_agency_id,
            values: -> { Location.where(location_type: [Location::LOCATION_TYPE_POLICE, Location::LOCATION_TYPE_PRISON, Location::LOCATION_TYPE_SECURE_TRAINING_CENTRE, Location::LOCATION_TYPE_SECURE_CHILDRENS_HOME]) },
          },
        )
      end

      def calculate_table
        raw_data = person_escort_records_with_moves
          .where(moves: { date: reporting_date })
          .group('moves.from_location_id', 'person_escort_records.handover_occurred_at IS NOT NULL')
          .count
        raw_data.default = 0

        transformed_data = ActiveSupport::HashWithIndifferentAccess.new(0)

        rows.each do |row_location|
          transformed_data[value_key('location', row_location)] = row_location.title
          transformed_data[value_key('type', row_location)] = row_location.location_type

          pers_handed_over = raw_data[[row_location.id, true]]
          pers_not_handed_over = raw_data[[row_location.id, false]]
          pers_total = pers_handed_over.to_i + pers_not_handed_over.to_i

          transformed_data[value_key('number_of_PERs', row_location)] = pers_total
          transformed_data[value_key('handover_percent', row_location)] =
            if pers_total.positive?
              number_to_percentage(100.0 * pers_handed_over.to_f / pers_total, precision: 1)
            end
        end

        transformed_data
      end
    end
  end
end
