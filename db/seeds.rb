# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

NotificationType.where(id: 'webhook').first_or_create!(title: 'Webhook')
NotificationType.where(id: 'email').first_or_create!(title: 'Email')
