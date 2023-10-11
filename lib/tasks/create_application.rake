# frozen_string_literal: true

namespace :auth do
  desc 'Create an OAuth2 authorised client application'
  task create_client_application: :environment do
    require 'doorkeeper/orm/active_record/application'

    puts "What's the application's name?"
    name = $stdin.gets.chomp
    application = Doorkeeper::Application.new(name:)

    keys = Supplier.pluck(:key).sort + %w[none]
    puts "Which application owner should your tokens be associated with? #{keys}"

    supplier_key = $stdin.gets.chomp
    abort('Error: unknown supplier, quitting.') unless keys.include?(supplier_key)

    supplier = supplier_key == 'none' ? nil : Supplier.find_by(key: supplier_key)

    application.owner = supplier if supplier.present?
    application.save!

    puts "Created OAuth2 client with (name: #{application.name})"
    puts "client_id: #{application.uid}"
    puts "client_secret: #{application.plaintext_secret}"
    puts "supplier: #{supplier_key}"
    puts "supplier_id: #{supplier&.id}"
  end
end
