# frozen_string_literal: true

require 'csv'

namespace :reference_data do
  desc 'create locations'
  task create_locations: :environment do
    puts 'Importing locations...'
    locations = NomisClient::Locations.get
    location_details = NomisClient::LocationDetails.get
    importer = Locations::Importer.new(locations, location_details)
    importer.call

    puts "NEW LOCATIONS (#{importer.added_locations.length}):"
    puts importer.added_locations.sort.join(', ')
    puts

    puts "UPDATED LOCATIONS (#{importer.updated_locations.length}):"
    puts importer.updated_locations.sort.join(', ')
    puts

    puts "DISABLED LOCATIONS (#{importer.disabled_locations.length}):"
    puts importer.disabled_locations.sort.join(', ')

    puts 'Updating locations...'
    Locations::Updater.call
  end

  desc 'update locations'
  task update_locations: :environment do
    puts 'Updating locations...'
    Locations::Updater.call
  end

  desc 'import postcodes'
  task import_postcodes: :environment do
    puts 'Importing postcodes...'
    postcodes = CSV.read('./lib/tasks/data/postcodes.csv', headers: true)
    importer = Locations::PostcodeImporter.new(postcodes)
    importer.call

    puts "\n\n#{importer.ignored_locations.count} locations ignored, #{importer.errored_locations.count} errors encountered."
    puts "Done. #{Location.kept.geocoded.count}/#{Location.kept.count} locations geocoded."
  end

  desc 'create ethnicities'
  task create_ethnicities: :environment do
    Ethnicities::Importer.new(NomisClient::Ethnicities.get).call
  end

  desc 'create genders'
  task create_genders: :environment do
    Genders::Importer.new(NomisClient::Genders.get).call
  end

  desc 'create identifier types'
  task create_identifier_types: :environment do
    IdentifierTypes::Importer.new.call
  end

  desc 'create assessment questions'
  task create_assessment_questions: :environment do
    AssessmentQuestions::Importer.new.call
  end

  desc 'create allocation complex cases'
  task create_allocation_complex_cases: :environment do
    AllocationComplexCases::Importer.new.call
  end

  desc 'create categories'
  task create_categories: :environment do
    categories = YAML.safe_load(File.read('./lib/tasks/data/categories.yml'))
    Categories::Importer.new(categories).call
  end

  desc 'create NOMIS alert mappings'
  task create_nomis_alerts: :environment do
    NomisAlerts::Importer.new.call
  end

  desc 'create regions'
  task create_regions: :environment do
    regions = YAML.safe_load(File.read('./lib/tasks/data/regions.yml'))
    Regions::Importer.new(regions).call
  end

  desc 'create suppliers'
  task create_suppliers: :environment do
    require 'active_record/fixtures'

    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('db/fixtures'), 'suppliers')
  end

  desc 'create prison transfer reasons'
  task create_prison_transfer_reasons: :environment do
    require 'active_record/fixtures'

    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('db/fixtures'), 'prison_transfer_reasons')
  end

  desc 'create links (with effective dates) between suppliers and locations'
  task create_supplier_locations: :environment do
    SupplierLocation.transaction do
      SupplierLocation.delete_all
      SupplierLocations::Importer.new('./lib/tasks/data/supplier_locations.yml').call
    end
  end

  desc 'create all of the necessary reference data'
  task create_all: :environment do
    %w[reference_data:create_locations
       reference_data:import_postcodes
       reference_data:create_ethnicities
       reference_data:create_genders
       reference_data:create_identifier_types
       reference_data:create_assessment_questions
       reference_data:create_allocation_complex_cases
       reference_data:create_nomis_alerts
       reference_data:create_categories
       reference_data:create_regions
       reference_data:create_suppliers
       reference_data:create_supplier_locations
       reference_data:create_prison_transfer_reasons].each do |task_name|
      puts "Running '#{task_name}' ..."
      Rake::Task[task_name].invoke
    end
  end
end
