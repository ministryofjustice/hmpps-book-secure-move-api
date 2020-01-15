# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
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

  desc 'create NOMIS alert mappings'
  task create_nomis_alerts: :environment do
    NomisAlerts::Importer.new(alert_codes: NomisClient::AlertCodes.get).call
  end

  desc 'create suppliers'
  task create_suppliers: :environment do
    require 'active_record/fixtures'

    ActiveRecord::FixtureSet.create_fixtures(File.join(Rails.root, 'db/fixtures'), 'suppliers')
  end

  desc 'create locations/suppliers relationship'
  task link_suppliers: :environment do
    supplier_locations = {
      geoamey: %w[
        AVS1
        AVS2
        AVS3
        CHE1
        CHE2
        CHE3
        CMB1
        CMB2
        CMB3
        CMB4
        CVL3
        DRB2
        DRB3
        DRB5
        DST1
        DST2
        DST3
        GCS1
        GWN1
        GWN2
        LCS1
        LCS2
        LCS3
        NRU1
        NRU2
        NRU3
        NRU4
        NTS1
        NTS2
        NTS3
        NTT1
        NTT3
        NWA1
        NWA4
        NWA5
        NYK1
        NYK2
        NYK3
        SFCUSU
        SRY016
        STCUSU
        STF2
        STF4
        SUS1
        SUS2
        SUS3
        SUS4
        SUS5
        SYP1
        SYP2
        SYP3
        WLT1
        WLT4
        WWM1
        WWM2
        WWM3
        WWM4
        WWM5
        WWM6
        WWM7
      ],
      serco: %w[
        BDS1
        BDS2
        BTP1
        BTP2
        BTP4
        BTP5
        CAM1
        CAM3
        CAM4
        CAM5
        CLP1
        ESX1
        ESX2
        ESX3
        ESX4
        ESX5
        ESX6
        ESX7
        HRT1
        HRT2
        MPS1
        MPS10
        MPS11
        MPS12
        MPS13
        MPS14
        MPS15
        MPS16
        MPS17
        MPS18
        MPS2
        MPS20
        MPS21
        MPS23
        MPS24
        MPS25
        MPS26
        MPS27
        MPS29
        MPS3
        MPS4
        MPS5
        MPS6
        MPS7
        MPS8
        MPS9
        NFL1
        NFL2
        NFL3
        NFL4
        SFL1
        SFL2
        MPS19
        MPS22
        MPS28
      ]
    }

    supplier_locations.each do |supplier_name, codes|
      supplier = Supplier.find_by(key: supplier_name.to_s)
      locations = codes.collect { |code| Location.find_by(nomis_agency_id: code) }.compact
      locations.each do |location|
        location.suppliers << supplier
      rescue ActiveRecord::RecordNotUnique
        puts "#{location.nomis_agency_id} <=> #{supplier_name} already exists"
      end
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
# rubocop:enable Metrics/BlockLength
