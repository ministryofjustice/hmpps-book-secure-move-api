# frozen_string_literal: true

namespace :auth do
  NO_OWNER = 'No owner'

  desc 'Create an OAuth2 authorised client application'
  task create_client_application: :environment do
    require 'doorkeeper/orm/active_record/application'
    require 'tty-prompt'

    prompt = TTY::Prompt.new

    name = prompt.ask("What's the application's name?")

    application = Doorkeeper::Application.new(name: name)

    suppliers = Supplier.all.each_with_object({}) do |supplier, accumulator|
      accumulator[supplier.name] = supplier.id
    end.merge(NO_OWNER => nil)
    owner_id = prompt.select('Is this application owned by a supplier?', suppliers)
    if owner_id != NO_OWNER
      owner = Supplier.find(owner_id)
      application.owner = owner
    end

    if application.save
      puts "Created OAuth2 client with (name: #{application.name})"
      puts "client_id: #{application.uid}"
      puts "client_secret: #{application.plaintext_secret}"
      puts "supplier: #{application.owner.name}" if application.owner
    else
      puts application.errors.full_messages
    end
  end
end
