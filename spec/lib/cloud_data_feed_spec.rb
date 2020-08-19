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
end
