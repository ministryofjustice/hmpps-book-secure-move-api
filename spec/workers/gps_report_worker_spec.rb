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
  let(:s3_object) { instance_double(Aws::S3::Object, presigned_url: 'aws_url') }

  around do |example|
    Timecop.freeze('2021-01-02 00:00:00')
    example.run
    Timecop.return
  end

  before do
    allow(GPSReport).to receive(:new).with(anything, 'geoamey').and_return(gps_reports[:geoamey])
    allow(GPSReport).to receive(:new).with(anything, 'serco').and_return(gps_reports[:serco])
    allow(Slack::Notifier).to receive(:new).and_return(slack_notifier)
    allow(slack_notifier).to receive(:post)
    allow(s3_object).to receive(:put)
    allow(Aws::S3::Resource).to receive(:new).and_return(instance_double(Aws::S3::Resource, bucket: instance_double(Aws::S3::Bucket, object: s3_object)))
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
            reasons,no_journeys,no_gps_data
            occurrences,1,2

            move ids
            ,#{move.id},#{move.id}
            ,,#{move.id}
          STR
          serco: <<~STR,
            reasons,no_gps_data
            occurrences,1

            move ids
            ,#{move.id}
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

      gps_report_worker.perform
    end

    it 'uploads the failure files to s3' do
      expect(s3_object).to have_received(:put).with(body: test_data[:failure_files][:geoamey])
      expect(s3_object).to have_received(:put).with(body: test_data[:failure_files][:serco])
    end

    it 'posts the expected results message to slack' do
      expect(slack_notifier).to have_received(:post).with(test_data[:chat_data])
    end
  end
end
