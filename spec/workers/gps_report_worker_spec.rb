require 'rails_helper'

RSpec.describe GPSReportWorker, type: :worker do
  subject(:gps_report_worker) { described_class.new }

  let(:gps_reports) do
    {
      geoamey: instance_double(GPSReport),
      serco: instance_double(GPSReport),
    }
  end
  let(:slack_client) { instance_double(Slack::Web::Client) }

  around do |example|
    Timecop.freeze('2021-01-02 00:00:00')
    example.run
    Timecop.return
  end

  before do
    allow(GPSReport).to receive(:new).with(anything, 'geoamey').and_return(gps_reports[:geoamey])
    allow(GPSReport).to receive(:new).with(anything, 'serco').and_return(gps_reports[:serco])
    allow(Slack::Web::Client).to receive(:new).and_return(slack_client)
    allow(slack_client).to receive(:chat_postMessage)
    allow(slack_client).to receive(:files_upload)
    stub_const('ENV', { 'SLACK_CHANNEL' => '#env_channel' })
  end

  context 'when geoamey passes and serco fails' do
    let(:move) { create(:move) }
    let(:chat_data) do
      {
        blocks: [
          {
            type: 'header',
            text: { type: 'plain_text', text: ':memo: GPS Data Report for 2020/12/26 - 2021/01/01', emoji: true },
          },
          { type: 'divider' },
          {
            type: 'section',
            text: {
              type: 'plain_text',
              text: ':white_check_mark: geoamey: 19/20 (95%) moves met the criteria',
              emoji: true,
            },
          },
          {
            type: 'section',
            text: {
              type: 'plain_text',
              text: ':x: serco: 4/7 (57.1%) moves met the criteria',
              emoji: true,
            },
          },
        ],
        channel: '#env_channel',
      }
    end
    let(:files) do
      {
        geoamey: {
          filename: 'geoamey_failures.csv',
          content: <<~STR,
            reasons,no_gps_data
            occurrences,1

            move ids
            ,#{move.id}
          STR
          channels: '#env_channel',
        },
        serco: {
          filename: 'serco_failures.csv',
          content: <<~STR,
            reasons,no_journeys,no_gps_data
            occurrences,1,2

            move ids
            ,#{move.id},#{move.id}
            ,,#{move.id}
          STR
          channels: '#env_channel',
        },
      }
    end

    before do
      allow(gps_reports[:geoamey]).to receive(:generate).and_return({
        failures: [{ move: move, reason: 'no_gps_data' }],
        move_count: 20,
      })
      allow(gps_reports[:serco]).to receive(:generate).and_return({
        failures: [{ move: move, reason: 'no_journeys' }, { move: move, reason: 'no_gps_data' }, { move: move, reason: 'no_gps_data' }],
        move_count: 7,
      })

      gps_report_worker.perform
    end

    it 'posts the expected results message to slack' do
      expect(slack_client).to have_received(:chat_postMessage).with(chat_data)
    end

    it 'posts the expected results files to slack' do
      expect(slack_client).to have_received(:files_upload).with(files[:geoamey])
      expect(slack_client).to have_received(:files_upload).with(files[:serco])
    end
  end
end
