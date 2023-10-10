# frozen_string_literal: true

require 'csv'

module NomisAlerts
  class Importer
    attr_accessor :alert_codes

    ALERT_CODE_TO_ASSESSMENT_QUESTION_KEY_MAPPINGS = {
      'HA' => :self_harm,
      'HA1' => :self_harm,
      'HA2' => :self_harm,
      'HC' => :self_harm,
      'HS' => :self_harm,
      'F1' => :self_harm,
      'CC1' => :hold_separately,
      'CC2' => :hold_separately,
      'CC3' => :hold_separately,
      'CC4' => :hold_separately,
      'CPC' => :hold_separately,
      'CPRC' => :hold_separately,
      'CSIP' => :hold_separately,
      'PC1' => :violent,
      'PC2' => :violent,
      'PC3' => :violent,
      'PL1' => :violent,
      'PL2' => :violent,
      'PL3' => :violent,
      'PVN' => :violent,
      'CA' => :violent,
      'MAS' => :health_issue,
      'MEP' => :special_vehicle,
      'MFL' => :special_vehicle,
      'MHT' => :health_issue,
      'PEEP' => :special_vehicle,
      'MSI' => :special_vehicle,
      'MSP' => :health_issue,
      'HID' => :health_issue,
      'UPIU' => :health_issue,
      'URCU' => :health_issue,
      'URS' => :health_issue,
      'USU' => :health_issue,
      'VU' => nil,
      'V45' => :hold_separately,
      'VOP' => :hold_separately,
      'V46' => :hold_separately,
      'VJOP' => :hold_separately,
      'V49G' => :hold_separately,
      'V49P' => :hold_separately,
      'VI' => :hold_separately,
      'VIP' => :hold_separately,
      'VLES' => :hold_separately,
      'SSHO' => nil,
      'SOR' => nil,
      'SC' => nil,
      'SONR' => nil,
      'TAP' => :not_to_be_released,
      'TAH' => :not_to_be_released,
      'TCPA' => :not_to_be_released,
      'TG' => :not_to_be_released,
      'TM' => :not_to_be_released,
      'TPR' => :not_to_be_released,
      'TSE' => :not_to_be_released,
      'WO' => :not_to_be_released,
      'OCVM' => :violent,
      'OHCO' => nil,
      'OIOM' => nil,
      'OCYP' => nil,
      'ONCR' => nil,
      'OPPO' => nil,
      'OVI' => nil,
      'LFC21' => nil,
      'LFC25' => nil,
      'LPQAA' => nil,
      'LCE' => nil,
      'AS' => nil,
      'RCP' => nil,
      'RDBS' => nil,
      'RAIC' => nil,
      'RDV' => :violent,
      'ROH' => :violent,
      'ROM' => :violent,
      'ROV' => :violent,
      'RCC' => :hold_separately,
      'RCS' => :hold_separately,
      'RKC' => nil,
      'RKS' => nil,
      'RPB' => :violent,
      'RPC' => :violent,
      'RST' => :violent,
      'RSS' => :violent,
      'RSP' => nil,
      'REG' => :hold_separately,
      'RDP' => :hold_separately,
      'RLG' => :hold_separately,
      'ROP' => :hold_separately,
      'RRV' => :hold_separately,
      'RTP' => :hold_separately,
      'RYP' => :hold_separately,
      'XA' => nil,
      'XB' => :violent,
      'XC' => :escape,
      'XCU' => :escape,
      'XSDEPORT' => :not_to_be_released,
      'XEBM' => :escape,
      'XEL' => :escape,
      'XER' => :escape,
      'XEAN' => nil,
      'XFO' => nil,
      'XGANG' => :hold_separately,
      'HPI' => :hold_separately,
      'XHT' => :hold_separately,
      'XILLENT' => :not_to_be_released,
      'XIT' => nil,
      'XNR' => :not_to_be_released,
      'XLDEPORT' => :not_to_be_released,
      'XOCGN' => nil,
      'XR' => :hold_separately,
      'XRF' => :hold_separately,
      'RNO121' => :hold_separately,
      'XSA' => :violent,
      'XTACT' => :violent,
      'XVL' => :violent,
      'XYA' => nil,
      'SE' => nil,
      'XSC' => :violent,
      'AAR' => nil,
      'ADSC' => nil,
      'BECTER' => nil,
      'OFNA' => nil,
      'OFR' => nil,
      'OISFL' => nil,
      'RCON' => nil,
      'RHI' => nil,
      'RLO' => nil,
      'RME' => nil,
      'ROTL' => nil,
      'RROTL' => nil,
      'SROTL' => nil,
      'TIERA' => nil,
      'TIERB' => nil,
      'TIERC' => nil,
      'TIERCT' => nil,
      'TIERD' => nil,
      'TIERDT' => nil,
      'XAB' => nil,
      'XCA' => nil,
      'XCCI' => nil,
      'XCI' => nil,
      'XCIC' => nil,
      'XCO' => nil,
      'XCSEA' => nil,
      'XD' => nil,
      'XIS' => nil,
      'XN' => nil,
      'XPHR' => nil,
      'XPOI' => nil,
      'XXRAY' => nil,
    }.freeze

    def initialize(alert_codes:)
      @alert_codes = alert_codes
    end

    def call
      alert_codes.each do |alert_code|
        import_alert(alert_code)
      end
    end

  private

    def nomis_alert_types
      @nomis_alert_types ||= NomisClient::AlertTypes.as_hash
    end

    def import_alert(alert)
      alert_type = alert_type_for(alert)

      if alert_type.nil?
        Rails.logger.info "Missing alert type #{alert[:parent_code]}"
        return
      end

      save_or_create_nomis_alert(alert, alert_type[:description])
    end

    def assessment_question_mapping(alert_code)
      key = ALERT_CODE_TO_ASSESSMENT_QUESTION_KEY_MAPPINGS[alert_code]

      key ? AssessmentQuestion.find_by(key:) : nil
    end

    def alert_type_for(alert)
      nomis_alert_types[alert[:parent_code]]
    end

    def save_or_create_nomis_alert(alert, type_description)
      code = alert[:code]
      type_code = alert[:parent_code]
      description = alert[:description]

      nomis_alert = NomisAlert.find_or_initialize_by(code:, type_code:)
      nomis_alert.update!(
        description:,
        type_description:,
        assessment_question: assessment_question_mapping(code),
      )
    end
  end
end
