# frozen_string_literal: true

require 'net/http'

namespace :wiremock do
  desc 'Download and install wiremock (NB: requires java)'
  task install: :environment do
    wiremock_version = '2.27.1'

    jar_file = Rails.root.join('spec/wiremock/wiremock-standalone.jar')
    uri = URI("https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/#{wiremock_version}/wiremock-standalone-#{wiremock_version}.jar")
    File.open(jar_file, 'wb') do |file|
      file.write(Net::HTTP.get(uri))
    end
    puts "Wiremock #{wiremock_version} installed at: #{jar_file}"

    puts 'NB: java is also required, you are currently running java version:'
    sh('java -version')
  end

  namespace :prison_api do
    desc 'Starts up prison-api wiremock on port 8888'
    task start: :environment do
      puts 'use ctrl-c to stop the server'
      sh('java -jar spec/wiremock/wiremock-standalone.jar --port 8888 --verbose --root-dir spec/wiremock/prison-api')
    end
  end
end
