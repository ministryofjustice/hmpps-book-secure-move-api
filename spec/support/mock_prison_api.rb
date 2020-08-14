# frozen_string_literal: true

RSpec.shared_context 'with mock prison-api' do
  # rubocop:disable RSpec/InstanceVariable
  before(:context) do
    # Make sure tests are using wiremocked Nomis, not real Nomis
    unless ENV['NOMIS_SITE'] == 'http://localhost:8888'
      raise "Expected NOMIS_SITE env var to point to wiremock server http://localhost:8888 (currently: #{ENV['NOMIS_SITE']})"
    end

    # Start up an internal wiremock server unless EXTERNAL_WIREMOCK=true
    unless ENV.fetch('EXTERNAL_WIREMOCK', 'false') == 'true'
      unless File.exist?('spec/wiremock/wiremock-standalone.jar')
        raise 'Please use either an external wiremock or install wiremock with: $ rake wiremock:install'
      end

      # start up a local wiremock server by running the jar
      @wiremock_server = ServiceMock::Server.new('standalone', 'spec/wiremock/')
      @wiremock_server.start do |server|
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
          connected = @wiremock_server.count('{"method": "GET"}').present?
        rescue Errno::ECONNREFUSED
          sleep 0.5
          retries += 1
        end
        break if connected || retries > 10
      end
      raise "Unable to connect to wiremock server on localhost port #{@wiremock_server.port}" unless connected
    end
  end

  after(:context) do
    if @wiremock_server.present?
      # shutdown wiremock server
      @wiremock_server.stop # rescue nil # ignore errors if we can't send the stop the server message
      @wiremock_server.process.stop
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
