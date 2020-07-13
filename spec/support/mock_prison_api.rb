# frozen_string_literal: true

RSpec.shared_context 'Mock prison-api' do
  before(:context) do
    # start up wiremock server
    @my_server = ServiceMock::Server.new('standalone-2.27.0', 'spec/wiremock/')
    @my_server.start do |server|
      server.port = 8888
      server.root_dir = 'prison-api'
      server.verbose = true
      server.wait_for_process = false
      server.record_mappings = false
    end

    retries = 0
    connected = false
    loop do
      # NB: it can take a couple of seconds before the mock server comes online
      begin
        connected = @my_server.count('{"method": "GET"}').present?
      rescue Errno::ECONNREFUSED
        sleep 0.5
        retries += 1
      end
      break if connected || retries > 10
    end
    raise "Unable to connect to wiremock server on localhost port #{@my_server.port}" unless connected
  end

  after(:context) do
    # shutdown wiremock server
    @my_server.stop # rescue nil # ignore errors if we can't send the stop the server message
    @my_server.process.stop
  end
end
