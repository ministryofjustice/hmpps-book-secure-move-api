require 'rails_helper'

RSpec.describe GPSReportWorker, type: :worker do
  subject(:gps_report_worker) { described_class.new }

  let(:gps_reports) do
    {
      geoamey: instance_double(GPSReport),
      serco: instance_double(GPSReport),
    }
  end

  let(:slack_notifier) { instance_double(Slack::Notifier) }
  let(:s3_id) { 'my_id' }
  let(:s3_key) { 'token123' }

  let(:s3_client) do
    Aws::S3::Client.new(
      access_key_id: s3_id,
      secret_access_key: s3_key,
      stub_responses: true,
    )
  end

  around do |example|
    Timecop.freeze('2021-01-02 00:00:00')
    ClimateControl.modify(
      'S3_AP_ACCESS_KEY_ID' => s3_id,
      'S3_AP_BUCKET_NAME' => 'moj-reg-dev',
      'S3_AP_SECRET_ACCESS_KEY' => s3_key,
      'S3_AP_PROJECT_PATH' => 'landing/hmpps-book-secure-move-api',
    ) do
      example.run
    end
    Timecop.return
  end

  before do
    allow(GPSReport).to receive(:new).with(anything, 'geoamey').and_return(gps_reports[:geoamey])
    allow(GPSReport).to receive(:new).with(anything, 'serco').and_return(gps_reports[:serco])
    allow(Slack::Notifier).to receive(:new).and_return(slack_notifier)
    allow(slack_notifier).to receive(:post)
    allow(Aws::S3::Client).to receive(:new).with(
      access_key_id: s3_id,
      secret_access_key: s3_key,
    ).and_return(s3_client)
  end

  context 'when geoamey passes and serco fails' do
    let(:move) { create(:move) }
    let(:test_data) do
      {
        chat_data: {
          blocks: [
            {
              type: 'header',
              text: { type: 'plain_text', text: ':memo: GPS Data Report for 2020/12/26 - 2021/01/01', emoji: true },
            },
            { type: 'divider' },
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: ':white_check_mark: geoamey: 19/20 (95%) moves met the criteria, <aws_url|failure file>',
              },
            },
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: ':x: serco: 4/7 (57.1%) moves met the criteria, <aws_url|failure file>',
              },
            },
          ],
        },
        failure_files: {
          geoamey: <<~STR,
            reasons,no_gps_data
            occurrences,1

            move ids
            ,#{move.id}
          STR
          serco: <<~STR,
            reasons,no_journeys,no_gps_data
            occurrences,1,2

            move ids
            ,#{move.id},#{move.id}
            ,,#{move.id}
          STR
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
      allow_any_instance_of(Aws::S3::Object).to receive(:presigned_url).and_return('aws_url') # rubocop:disable RSpec/AnyInstance

      gps_report_worker.perform
    end

    it 'uploads the failure files to s3' do
      expect(s3_client.api_requests.first.slice(:operation_name, :params)).to eq({
        operation_name: :put_object,
        params: {
          acl: 'bucket-owner-full-control',
          body: test_data[:failure_files][:geoamey],
          bucket: 'moj-reg-dev',
          key: 'landing/hmpps-book-secure-move-api/data/database_name=gps_report/table_name=gps_reports_geoamey/extraction_timestamp=20201226000000Z/2020-12-26-2021-01-01-gps-report.csv',
          server_side_encryption: 'AES256',
        },
      })
      expect(s3_client.api_requests.second.slice(:operation_name, :params)).to eq(
        operation_name: :put_object,
        params: {
          acl: 'bucket-owner-full-control',
          body: test_data[:failure_files][:serco],
          bucket: 'moj-reg-dev',
          key: 'landing/hmpps-book-secure-move-api/data/database_name=gps_report/table_name=gps_reports_serco/extraction_timestamp=20201226000000Z/2020-12-26-2021-01-01-gps-report.csv',
          server_side_encryption: 'AES256',
        },
      )
    end

    it 'posts the expected results message to slack' do
      expect(slack_notifier).to have_received(:post).with(test_data[:chat_data])
    end
  end
end
