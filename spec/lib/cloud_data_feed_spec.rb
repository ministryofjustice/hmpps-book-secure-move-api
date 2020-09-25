require 'rails_helper'

RSpec.describe CloudDataFeed do
  before do
    Aws.config.update(stub_responses: true)
    Timecop.freeze(Time.local(2020, 1, 30))
  end

  after do
    Timecop.return
  end

  it 'writes a file on S3 and return the full_name' do
    full_name = described_class.new('bucket_name')
                    .write('some content', 'report.json')

    expect(full_name).to eq('2020/01/30/2020-01-30-report.json')
  end

  context 'when a report date is specified' do
    let(:report_date) { Date.new(2020, 1, 15) }

    it 'creates a file and names it base on the report date ' do
      full_name = described_class.new('bucket_name')
                                 .write('some content', 'report.json', report_date)

      expect(full_name).to eq('2020/01/15/2020-01-15-report.json')
    end
  end
end
