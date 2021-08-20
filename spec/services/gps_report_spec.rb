# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GPSReport do
  subject(:gps_report) { described_class.new(date_range, serco.key) }

  let(:serco) { create(:supplier, :serco) }
  let(:date_range) { Date.new(2021, 1, 1)..Date.new(2021, 1, 7) }
  let(:athena_client) { instance_double(Aws::Athena::Client) }

  before do
    allow(athena_client).to receive(:start_query_execution)
    allow(athena_client).to receive(:get_query_results)
    allow(athena_client).to receive(:get_query_execution).and_return(Aws::Athena::Types::GetQueryExecutionOutput.new(query_execution: Aws::Athena::Types::QueryExecution.new(status: Aws::Athena::Types::QueryExecutionStatus.new(state: 'SUCCEEDED'))))
    allow(Aws::Athena::Client).to receive(:new).and_return(athena_client)
    stub_const('ENV', { 'ATHENA_WORK_GROUP' => 'env_work_group', 'ATHENA_DATABASE' => 'env_database' })
  end

  context 'when there are no moves within the time period' do
    it 'returns the expected values' do
      expect(gps_report.generate).to eq({
        failures: [],
        move_count: 0,
      })

      expect(athena_client).not_to have_received(:start_query_execution)
    end
  end

  context 'when there are moves within the time period' do
    let!(:moves) do
      {
        passing_move: create(:move, :completed, :with_journey, supplier: serco, date: '2021-01-01'),
        no_gps_data_move: create(:move, :completed, :with_journey, supplier: serco, date: '2021-01-07'),
        gps_data_gap_move: create(:move, :completed, :with_journey, supplier: serco, date: '2021-01-02'),
        no_journey_move: create(:move, :completed, supplier: serco, date: '2021-01-06'),
        requested_move: create(:move, :requested, :with_journey, supplier: serco, date: '2021-01-03'),
        no_supplier_move: create(:move, :completed, :with_journey, date: '2021-01-05'),
        too_early_move: create(:move, :completed, :with_journey, supplier: serco, date: '2019-12-31'),
        too_late_move: create(:move, :completed, :with_journey, supplier: serco, date: '2021-01-08'),
      }
    end
    let(:gps_data_res) do
      instance_double(
        Aws::Athena::Types::GetQueryResultsOutput,
        result_set: instance_double(
          Aws::Athena::Types::ResultSet,
          rows: [
            instance_double(
              Aws::Athena::Types::Row,
              data: [
                instance_double(Aws::Athena::Types::Datum, var_char_value: 'journey_id'),
                instance_double(Aws::Athena::Types::Datum, var_char_value: 'tracking_timestamp'),
              ],
            ),
            instance_double(
              Aws::Athena::Types::Row,
              data: [
                instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:passing_move].journeys.first.id),
                instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:00:08+01:00'),
              ],
            ),
            instance_double(
              Aws::Athena::Types::Row,
              data: [
                instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:passing_move].journeys.first.id),
                instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:01:08+01:00'),
              ],
            ),
            instance_double(
              Aws::Athena::Types::Row,
              data: [
                instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:passing_move].journeys.first.id),
                instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:01:28+01:00'),
              ],
            ),
            instance_double(
              Aws::Athena::Types::Row,
              data: [
                instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:gps_data_gap_move].journeys.first.id),
                instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:00:08+01:00'),
              ],
            ),
            instance_double(
              Aws::Athena::Types::Row,
              data: [
                instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:gps_data_gap_move].journeys.first.id),
                instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:01:09+01:00'),
              ],
            ),
          ],
        ),
        next_token: nil,
      )
    end
    let(:repair_res) do
      instance_double(
        Aws::Athena::Types::GetQueryResultsOutput,
        result_set: instance_double(
          Aws::Athena::Types::ResultSet,
          rows: [],
        ),
        next_token: nil,
      )
    end

    before do
      moves_with_journeys = [moves[:passing_move], moves[:no_gps_data_move], moves[:gps_data_gap_move]].sort_by(&:id)

      allow(athena_client).to receive(:start_query_execution).with(
        {
          work_group: 'env_work_group',
          query_execution_context: {
            database: 'env_database',
          },
          query_string: "MSCK REPAIR TABLE #{serco.key};",
        },
      ).and_return(instance_double(Aws::Athena::Types::StartQueryExecutionOutput, query_execution_id: 'repair'))

      allow(athena_client).to receive(:start_query_execution).with(
        {
          work_group: 'env_work_group',
          query_execution_context: {
            database: 'env_database',
          },
          query_string: "select journey_id, tracking_timestamp from #{serco.key} where journey_id in ('#{moves_with_journeys.flat_map(&:journeys).map(&:id).join("', '")}') order by journey_id, tracking_timestamp;",
        },
      ).and_return(instance_double(Aws::Athena::Types::StartQueryExecutionOutput, query_execution_id: 'gps_data'))

      allow(athena_client).to receive(:get_query_results).with(query_execution_id: 'gps_data', next_token: nil).and_return(gps_data_res)
      allow(athena_client).to receive(:get_query_results).with(query_execution_id: 'repair', next_token: nil).and_return(repair_res)
    end

    it 'returns the expected values' do
      res = gps_report.generate
      res[:failures].sort_by! { |f| f[:move].id }

      expect(res).to eq({
        failures: [
          { move: moves[:no_gps_data_move], reason: 'no_gps_data' },
          { move: moves[:gps_data_gap_move], reason: 'gps_data_gap' },
          { move: moves[:no_journey_move], reason: 'no_journeys' },
        ].sort_by { |f| f[:move].id },
        move_count: 4,
      })

      expect(athena_client).to have_received(:get_query_results).with(query_execution_id: 'repair', next_token: nil)
    end

    context 'when athena returns a next_token' do
      let(:gps_data_res1) do
        instance_double(
          Aws::Athena::Types::GetQueryResultsOutput,
          result_set: instance_double(
            Aws::Athena::Types::ResultSet,
            rows: [
              instance_double(
                Aws::Athena::Types::Row,
                data: [
                  instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:passing_move].journeys.first.id),
                  instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:01:50+01:00'),
                ],
              ),
            ],
          ),
          next_token: 'token2',
        )
      end

      let(:gps_data_res2) do
        instance_double(
          Aws::Athena::Types::GetQueryResultsOutput,
          result_set: instance_double(
            Aws::Athena::Types::ResultSet,
            rows: [
              instance_double(
                Aws::Athena::Types::Row,
                data: [
                  instance_double(Aws::Athena::Types::Datum, var_char_value: moves[:passing_move].journeys.first.id),
                  instance_double(Aws::Athena::Types::Datum, var_char_value: '2021-01-01T07:03:10+01:00'),
                ],
              ),
            ],
          ),
          next_token: nil,
        )
      end

      before do
        allow(gps_data_res).to receive(:next_token).and_return('token1')
        allow(athena_client).to receive(:get_query_results).with(query_execution_id: 'gps_data', next_token: 'token1').and_return(gps_data_res1)
        allow(athena_client).to receive(:get_query_results).with(query_execution_id: 'gps_data', next_token: 'token2').and_return(gps_data_res2)
      end

      it 'returns the expected values' do
        res = gps_report.generate
        res[:failures].sort_by! { |f| f[:move].id }

        expect(res).to eq({
          failures: [
            { move: moves[:no_gps_data_move], reason: 'no_gps_data' },
            { move: moves[:gps_data_gap_move], reason: 'gps_data_gap' },
            { move: moves[:passing_move], reason: 'gps_data_gap' },
            { move: moves[:no_journey_move], reason: 'no_journeys' },
          ].sort_by { |f| f[:move].id },
          move_count: 4,
        })

        expect(athena_client).to have_received(:get_query_results).with(query_execution_id: 'repair', next_token: nil)
      end
    end

    context 'when athena raises an unexpected error' do
      let(:error) { Aws::Athena::Errors::InvalidRequestException.new('invalid', 'request was invalid') }

      before do
        allow(athena_client).to receive(:get_query_results).and_raise(error)
        query_execution = Aws::Athena::Types::GetQueryExecutionOutput.new(query_execution: Aws::Athena::Types::QueryExecution.new(status: Aws::Athena::Types::QueryExecutionStatus.new(state: 'FAILED')))
        allow(athena_client).to receive(:get_query_execution).and_return(query_execution)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'is raised and logs the query_execution_id in sentry' do
        expect { gps_report.generate }.to raise_exception(error)
        expect(Sentry).to have_received(:capture_exception).with(error, extra: { query_execution_id: 'repair' })
      end
    end
  end
end
