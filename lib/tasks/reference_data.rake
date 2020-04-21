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

  desc 'create complex cases'
  task create_complex_cases: :environment do
    ComplexCases::Importer.new.call
  end

  desc 'create NOMIS alert mappings'
  task create_nomis_alerts: :environment do
    NomisAlerts::Importer.new(alert_codes: NomisClient::AlertCodes.get).call
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
      locations = codes.collect { |code| Location.find_by(nomis_agency_id: code) }.compact
      supplier.locations = locations
    end

    puts
    puts 'Summary of relationships'
    puts '========================'
    Supplier.all.each do |supplier|
      puts
      puts "Supplier #{supplier.name}:"
      supplier.locations.each do |location|
        puts " - #{location.nomis_agency_id}: #{location.title}"
      end
    end
  end
end
