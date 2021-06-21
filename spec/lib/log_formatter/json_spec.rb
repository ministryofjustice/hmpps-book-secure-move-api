require 'log_formatter/json'

RSpec.describe LogFormatter::Json do
  subject(:formatter) { described_class.new }

  let(:severity) { 'DEBUG' }
  let(:timestamp) { '2020-07-03T15:33:17+01:00' }
  let(:expected) { "#{JSON.dump(expected_json)}\n" }

  context 'when the message argument is not parsable json' do
    let(:msg) { '[ElasticAPM] Agent disabled with `enabled: false' }

    let(:expected_json) do
      {
        'severity' => 'DEBUG',
        'timestamp' => '2020-07-03T15:33:17+01:00',
        'msg' => '[ElasticAPM] Agent disabled with `enabled: false',
      }
    end

    it 'returns the correctly formatted log line' do
      expect(formatter.call(severity, timestamp, nil, msg)).to eq(expected)
    end
  end

  context 'when the message argument is parsable json' do
    let(:msg) { '{"method":"GET","path":"/api/people","format":"json","controller":"Api::PeopleController","action":"index","status":200,"duration":760.87,"view":50.15,"db":57.81}' }

    let(:expected_json) do
      {
        'severity' => 'DEBUG',
        'timestamp' => '2020-07-03T15:33:17+01:00',
        'method' => 'GET',
        'path' => '/api/people',
        'format' => 'json',
        'controller' => 'Api::PeopleController',
        'action' => 'index',
        'status' => 200,
        'duration' => 760.87,
        'view' => 50.15,
        'db' => 57.81,
      }
    end

    it 'returns the correctly formatted log line' do
      expect(formatter.call(severity, timestamp, nil, msg)).to eq(expected)
    end
  end
end
