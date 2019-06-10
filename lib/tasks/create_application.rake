# frozen_string_literal: true

namespace :auth do
  desc 'Create an OAuth2 authorised client application'
  task create_client_application: :environment do
    require 'doorkeeper/orm/active_record/application'

    if ENV['NAME'].blank?
      puts 'Usage: rake auth:create_client_application NAME=name'
      exit
    end

    @application = Doorkeeper::Application.new(name: ENV['NAME'])
    if @application.save
      puts "Created OAuth2 client with (name: #{@application.name})"
      puts "client_id: #{@application.uid}"
      puts "client_secret: #{@application.plaintext_secret}"
    else
      puts @application.errors.full_messages
    end
  end
end
