require 'rails_helper'

RSpec.describe CloudData::ReportsFeed do
  let(:s3_client) do
    Aws::S3::Client.new(
      access_key_id: s3_id,
      secret_access_key: s3_key,
      stub_responses: true,
    )
  end

  let(:full_path) do
    'landing/hmpps-book-secure-move-api/data/' \
    'database_name=feeds_report/' \
    'table_name=moves/' \
    'extraction_timestamp=20200129000000Z/' \
    '2020-01-29-moves.jsonl'
  end

  let(:table) { 'moves' }
  let(:content) { 'some content' }
  let(:bucket_name) { 'bucket_name' }
  let(:s3_id) { 'my_id' }
  let(:s3_key) { 'token123' }

  before do
    allow(Aws::S3::Client).to receive(:new).with(
      access_key_id: s3_id,
      secret_access_key: s3_key,
    ).and_return(s3_client)

    Timecop.freeze(Time.zone.local(2020, 1, 30))
  end

  after do
    Timecop.return
  end

  around do |example|
    ClimateControl.modify(
      'S3_REPORTING_ACCESS_KEY_ID' => s3_id,
      'S3_REPORTING_SECRET_ACCESS_KEY' => s3_key,
      'S3_REPORTING_PROJECT_PATH' => 'landing/hmpps-book-secure-move-api',
    ) do
      example.run
    end
  end

  it 'writes a file on S3 and return the full_name' do
    full_name = described_class.new(bucket_name)
                    .write(content, table)

    expect(full_name).to eq(full_path)
  end

  it 'calls the S3 SDK with the correct data' do
    described_class.new(bucket_name).write(content, table)

    expect(s3_client.api_requests.first.slice(:operation_name, :params)).to eq({
      operation_name: :put_object,
      params: {
        acl: 'bucket-owner-full-control',
        body: content,
        bucket: bucket_name,
        key: full_path,
        server_side_encryption: 'AES256',
      },
    })
  end

  context 'when a report date is specified' do
    let(:report_date) { Date.new(2020, 1, 15) }

    it 'creates a file and names it based on the report date' do
      full_name = described_class.new(bucket_name)
                                 .write(content, table, report_date)

      expect(full_name).to eq(
        'landing/hmpps-book-secure-move-api/data/' \
        'database_name=feeds_report/' \
        'table_name=moves/' \
        'extraction_timestamp=20200115000000Z/' \
        '2020-01-15-moves.jsonl',
      )
    end
  end
end
