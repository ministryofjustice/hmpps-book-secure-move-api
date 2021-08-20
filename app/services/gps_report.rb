# frozen_string_literal: true

class InvalidSupplierError < StandardError; end

class GPSReport
  include ActionView::Helpers::TextHelper

  def initialize(date_range, supplier_name)
    @supplier = Supplier.find_by(key: supplier_name)
    raise InvalidSupplierError, "Invalid supplier: `#{supplier_name}`. Valid values are: `#{Supplier.pluck(:key).join('`, `')}`." if @supplier.nil?

    @from_date = date_range.first
    @to_date = date_range.last
  end

  def generate
    Rails.logger.info "Generating GPS Data Report for #{@supplier.key} from #{@from_date} to #{@to_date}."

    if journeys.empty?
      Rails.logger.info "No #{@supplier.key} journeys found for the specified period."
      return {
        failures: [],
        move_count: 0,
      }
    end

    Rails.logger.info "Found #{pluralize(moves.count, "#{@supplier.key} move")} with #{pluralize(journeys.count, 'journey')}."

    {
      failures: failures,
      move_count: moves.count,
    }
  end

private

  def failures
    @failures ||= moves.filter_map { |move|
      { move: move, reason: 'no_journeys' } if move.journeys.empty?
    }.concat(journey_failures)
  end

  def journey_failures
    failures = journeys.filter_map do |journey|
      gps_data = gps_data_map[journey.id]
      next { move: journey.move, reason: 'no_gps_data' } if gps_data.blank?

      intervals = gps_data.each_with_index.filter_map { |t, i| i < gps_data.count - 1 ? gps_data[i + 1] - t : nil }
      { move: journey.move, reason: 'gps_data_gap' } if intervals.max > 60.seconds
    end
    failures.uniq { |f| f[:move] }
  end

  def gps_data_map
    @gps_data_map ||= begin
      repair_table

      Rails.logger.info "Fetching #{@supplier.key} GPS data points."

      time_since = TimeSince.new
      res = athena_query("select journey_id, tracking_timestamp from #{@supplier.key} where journey_id in ('#{journeys.map(&:id).join("', '")}') order by journey_id, tracking_timestamp;")
      rows = res.flat_map { |r| r.result_set.rows }[1..]

      gps_data_map = rows.each_with_object({}) do |data_row, data_map|
        journey_id, timestamp = *data_row.data.map(&:var_char_value)
        data_map[journey_id] = [] if data_map[journey_id].nil?

        data_map[journey_id] << Time.zone.parse(timestamp)
      end

      Rails.logger.info "Fetched #{pluralize(rows.count, "#{@supplier.key} GPS data point")} in #{pluralize(time_since.get, 'second')}."

      gps_data_map
    end
  end

  def journeys
    @journeys ||= moves.flat_map(&:journeys)
  end

  def moves
    @moves ||= Move.includes(:journeys).where(status: 'completed', date: @from_date..@to_date, supplier: @supplier).order(:id).find_in_batches.to_a.flatten
  end

  def repair_table
    Rails.logger.info "Repairing table `#{@supplier.key}`."

    time_since = TimeSince.new
    athena_query("MSCK REPAIR TABLE #{@supplier.key};")

    Rails.logger.info "#{@supplier.key} table repair took #{pluralize(time_since.get, 'second')}."
  end

  def athena_query(query)
    query_id = athena_client.start_query_execution({
      work_group: ENV['ATHENA_WORK_GROUP'],
      query_execution_context: { database: ENV['ATHENA_DATABASE'] },
      query_string: query,
    }).query_execution_id

    sleep 1.second while %w[QUEUED RUNNING].include?(athena_client.get_query_execution(query_execution_id: query_id).query_execution.status.state)

    results = []

    next_token = nil
    while results.count.zero? || next_token.present?
      res = athena_client.get_query_results(query_execution_id: query_id, next_token: next_token)
      results << res
      next_token = res.next_token
    end

    results
  rescue Aws::Athena::Errors::InvalidRequestException => e
    Sentry.capture_exception(e, extra: { query_execution_id: query_id })
    raise e
  end

  def athena_client
    @athena_client ||= Aws::Athena::Client.new(
      region: ENV['ATHENA_REGION'],
      credentials: Aws::Credentials.new(ENV['ATHENA_ACCESS_KEY_ID'], ENV['ATHENA_SECRET_ACCESS_KEY']),
    )
  end
end
