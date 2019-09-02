# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alerts::Importer do
  subject(:importer) do
    described_class.new(
      profile: profile,
      alerts: alerts
    )
  end

  let(:person) { create :person }
  let(:profile) { person.latest_profile }
  let(:alerts) do
    [
      {
        alert_id: 1,
        alert_type: 'X',
        alert_type_description: 'Security',
        alert_code: 'XVL',
        alert_code_description: 'Violent',
        comment: 'Threatening to take staff hostage',
        created_at: '2018-07-29',
        expires_at: nil,
        expired: false,
        active: true,
        rnum: 1
      },
      {
        alert_id: 2,
        alert_type: 'X',
        alert_type_description: 'Security',
        alert_code: 'XEL',
        alert_code_description: 'Escape List',
        comment: 'Caught in possession of a rock hammer',
        created_at: '2017-06-15',
        expires_at: nil,
        expired: false,
        active: true,
        rnum: 2
      }
    ]
  end

  it 'works' do
    importer.call
    expect(profile.assessment_answers.count).to be 2
  end
end
