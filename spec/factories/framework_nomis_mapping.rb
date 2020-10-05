# frozen_string_literal: true

FactoryBot.define do
  factory :framework_nomis_mapping do
    raw_nomis_mapping do
      {
        alert_id: 2,
        alert_type: 'X',
        alert_type_description: 'Security',
        alert_code: 'XVL',
        alert_code_description: 'Violent',
        comment: 'SIR GP162/11 17/01/11 - threatening to take staff hostage',
        created_at: '2013-03-29',
        expires_at: '2018-06-08',
        expired: true,
        active: false,
        offender_no: 'A9127EK',
      }
    end
    code { 'XAB' }
    code_type { 'alert' }
    code_description { 'Violent' }
    comments { 'SIR GP162/11 17/01/11 - threatening to take staff hostage' }
    creation_date { '2013-03-29' }
    expiry_date { '2018-06-08' }
  end
end
