# frozen_string_literal: true

RSpec.shared_context 'Mock prison-api' do
  before(:context) do
    # Start up a local wiremock server unless there is a WIREMOCK_URL env var defined
    unless ENV['WIREMOCK_URL'].present?
      # start up a local wiremock server by running the jar
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
  end

  after(:context) do
    unless ENV['WIREMOCK_URL'].present?
      # shutdown wiremock server
      @my_server.stop # rescue nil # ignore errors if we can't send the stop the server message
      @my_server.process.stop
      end
    end
end
