# frozen_string_literal: true

require 'csv'

module NomisAlerts
  class Importer
    attr_accessor :alert_codes

    ALERT_MAPPINGS = {
      'HA' => :self_harm,
      'HA1' => :self_harm,
      'HA2' => :self_harm,
      'HC' => :self_harm,
      'HS' => :self_harm,
      'CC1' => :hold_separately,
      'CC2' => :hold_separately,
      'CC3' => :hold_separately,
      'CC4' => :hold_separately,
      'CPC' => :hold_separately,
      'CPRC' => :hold_separately,
      'PC1' => :violent,
      'PC2' => :violent,
      'PC3' => :violent,
      'PL1' => :violent,
      'PL2' => :violent,
      'PL3' => :violent,
      'PVN' => :violent,
      'MAS' => :health_issue,
      'MEP' => :special_vehicle,
      'MFL' => :special_vehicle,
      'MHT' => :health_issue,
      'PEEP' => :special_vehicle,
      'MSI' => :special_vehicle,
      'MSP' => :health_issue,
      'VU' => nil,
      'V45' => :hold_separately,
      'VOP' => :hold_separately,
      'V46' => :hold_separately,
      'VJOP' => :hold_separately,
      'V49G' => :hold_separately,
      'V49P' => :hold_separately,
      'VI' => :hold_separately,
      'SSHO' => nil,
      'SOR' => nil,
      'SC' => nil,
      'SONR' => nil,
      'TAP' => nil,
      'TAH' => nil,
      'TCPA' => nil,
      'TG' => nil,
      'TM' => nil,
      'TPR' => nil,
      'TSE' => nil,
      'WO' => nil,
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
      'XSDEPORT' => :escape,
      'XEBM' => :escape,
      'XEL' => :escape,
      'XER' => :escape,
      'XEAN' => nil,
      'XFO' => nil,
      'XGANG' => :hold_separately,
      'HPI' => :hold_separately,
      'XHT' => :hold_separately,
      'XILLENT' => nil,
      'XIT' => nil,
      'XNR' => nil,
      'XLDEPORT' => nil,
      'XOCGN' => nil,
      'XR' => :hold_separately,
      'XRF' => :hold_separately,
      'XSA' => :violent,
      'XTACT' => nil,
      'XVL' => :violent,
      'XYA' => nil,
      'SE' => nil,
      'XSC' => nil,
      'F1' => nil,
    }.freeze

    def initialize(alert_codes:)
      self.alert_codes = alert_codes
    end

    def call
      alert_codes.each do |alert|
        import_alert(alert)
      end
    end

  private

    def alert_types
      @alert_types ||= NomisClient::AlertTypes.as_hash
    end

    def import_alert(alert)
      alert_type = alert_type_for(alert)
      puts "Missing alert type #{alert[:parent_code]}" if alert_type.nil?
      return if alert_type.nil?

      record = NomisAlert.find_or_initialize_by(code: alert[:code], type_code: alert[:parent_code])
      record.update!(
        description: alert[:description],
        type_description: alert_type[:description],
        assessment_question: assessment_question_mapping(alert[:code]),
      )
    end

    def assessment_question_mapping(alert_code)
      key = ALERT_MAPPINGS[alert_code]
      key ? AssessmentQuestion.find_by(key: key) : nil
    end

    def alert_type_for(alert)
      alert_types[alert[:parent_code]]
    end
  end
end
