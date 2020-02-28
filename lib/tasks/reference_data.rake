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

    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('db/fixtures'), 'suppliers')
  end

  desc 'create prison transfer reasons'
  task create_prison_transfer_reasons: :environment do
    require 'active_record/fixtures'

    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('db/fixtures'), 'prison_transfer_reasons')
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
        DC1
        DC2
        DC3
        DC4
        DC5
        DC6
        DC7
        DHM1
        DHM2
        DHM3
        DHM4
        DHM5
        DHM6
        DP1
        DP2
        DP3
        DP4
        DP5
        DP6
        DP7
        DRB2
        DRB3
        DRB5
        DST1
        DST2
        DST3
        GCS1
        GMP1
        GMP2
        GMP3
        GMP4
        GMP5
        GMP6
        GMP7
        GMP8
        GMP9
        GWN1
        GWN2
        HMB2
        HMB3
        HMB4
        HMB5
        HNT1
        HNT2
        HNT3
        HNT4
        HNT6
        KNT1
        KNT2
        KNT3
        KNT4
        KNT5
        KNT6
        KNT7
        KNT8
        LAN1
        LAN2
        LAN3
        LAN4
        LAN5
        LAN6
        LCS1
        LCS2
        LCS3
        LNC1
        LNC2
        LNC3
        LNC4
        MRS1
        MRS2
        MRS3
        MRS4
        MRS5
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
        NWA2
        NWA4
        NWA5
        NYK1
        NYK2
        NYK3
        SCH1
        SCH2
        SCH3
        SCH4
        SCH5
        SCH6
        SCH8
        SCH9
        STC2
        STC3
        SFCUSU
        SRY016
        SRY1
        SRY2
        SRY3
        SRY4
        STCUSU
        STF1
        STF2
        STF4
        SUS1
        SUS2
        SUS3
        SUS4
        SUS5
        SWL1
        SWL2
        SWL3
        SWL4
        SYP1
        SYP2
        SYP3
        TVP1
        TVP2
        TVP3
        TVP4
        TVP5
        TVP6
        TVP7
        TVP8
        WLT1
        WLT4
        WMP2
        WMP3
        WMP4
        WMP5
        WMP7
        WMP8
        WWM1
        WWM2
        WWM3
        WWM4
        WWM5
        WWM6
        WWM7
        WYP1
        WYP2
        WYP3
        WYP4
        WYP5
        WYP6
        WYP7
        WYP8
        WYP9
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
        MPS19
        MPS2
        MPS20
        MPS21
        MPS22
        MPS23
        MPS24
        MPS25
        MPS26
        MPS27
        MPS28
        MPS29
        MPS3
        MPS30
        MPS31
        MPS32
        MPS33
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
      ],
    }

    # Set the supplier locations. This is an authoritative change, making the
    # suppliers have exactly the locations listed above.
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
# rubocop:enable Metrics/BlockLength
