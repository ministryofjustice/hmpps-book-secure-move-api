# frozen_string_literal: true

namespace :reference_data do
  desc 'create locations'
  task create_locations: :environment do
    Locations::Importer.new(NomisClient::Locations.get).call
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

  desc 'create NOMIS alert mappings'
  task create_nomis_alerts: :environment do
    NomisAlerts::Importer.new(alert_codes: NomisClient::AlertCodes.get).call
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

  desc 'create locations/suppliers relationship'
  task link_suppliers: :environment do
    supplier_locations = YAML.safe_load(File.read('./lib/tasks/data/supplier_locations.yml'))

    # Set the supplier locations. This is an authoritative change, making the
    # suppliers have exactly the locations listed in supplier_locations.yml
    supplier_locations.each do |supplier_name, codes|
      supplier = Supplier.find_by(key: supplier_name.to_s)
      locations_in_yaml = codes.collect { |code| Location.find_by(nomis_agency_id: code) }.compact

      existing_location_keys = supplier.locations.pluck(:key)
      yaml_location_keys = locations_in_yaml.map(&:key)

      if have_locations_changed?(existing_location_keys, yaml_location_keys)
        supplier.locations = locations_in_yaml

        removed_locations = existing_location_keys - yaml_location_keys
        added_locations = yaml_location_keys - existing_location_keys

        Raven.capture_message("Locations updated for the Supplier: #{supplier.name}. ",
                              extra: {
                                  added_locations: added_locations,
                                  removed_locations: removed_locations,
                              },
                              level: 'warning')

        puts '- - -'
        puts "Locations removed from Supplier '#{supplier.name}': #{removed_locations}"
        puts "Locations added to Supplier '#{supplier.name}': #{added_locations}"
      else
        puts "Locations for the Supplier '#{supplier.name}' have not changed."
      end
    end
  end

  desc 'create all of the necessary reference data'
  task create_all: :environment do
    %w[reference_data:create_locations
       reference_data:create_ethnicities
       reference_data:create_genders
       reference_data:create_identifier_types
       reference_data:create_assessment_questions
       reference_data:create_allocation_complex_cases
       reference_data:create_nomis_alerts
       reference_data:create_regions
       reference_data:create_suppliers
       reference_data:create_prison_transfer_reasons
       reference_data:link_suppliers].each do |task_name|
      puts "Running '#{task_name}' ..."
      Rake::Task[task_name].invoke
    end
  end

private

  def have_locations_changed?(locations1, locations2)
    ((locations1 - locations2) + (locations2 - locations1)).any?
  end
end
