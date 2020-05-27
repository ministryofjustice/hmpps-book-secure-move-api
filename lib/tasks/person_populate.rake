# TODO: Remove this once we've migrated all profile attributes to a person and are updating these attributes dynamically
namespace :person do
  desc 'Populates a person with profile field values'
  task populate: :environment do
    total = Person.count

    Person.find_each do |person|
      PersonPopulator.new(person, person.latest_profile).call
    end

    puts "#{total} people have been successfully populated."
  end
end
