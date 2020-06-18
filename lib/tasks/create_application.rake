# frozen_string_literal: true

namespace :auth do
  desc 'Create an OAuth2 authorised client application'
  task create_client_application: :environment do
    require 'doorkeeper/orm/active_record/application'

    puts "What's the application's name?"
    name = STDIN.gets.chomp

    application = Doorkeeper::Application.new(name: name)

    suppliers = Supplier.all.each_with_object({}) { |supplier, accumulator|
      accumulator[supplier.name.downcase] = supplier.id
    }.merge('none' => nil)

    puts "Which application owner should your tokens be associated with? #{suppliers.keys}"
    supplier = STDIN.gets.chomp
    supplier_id = suppliers[supplier]

    application.owner_id = supplier_id if supplier_id.present?
    application.save!

    puts "Created OAuth2 client with (name: #{application.name})"
    puts "client_id: #{application.uid}"
    puts "client_secret: #{application.plaintext_secret}"
    puts "supplier: #{supplier}"
  end
end
