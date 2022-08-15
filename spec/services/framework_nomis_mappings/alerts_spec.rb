# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::Alerts do
  it 'builds a framework NOMIS mapping for active alerts from NOMIS' do
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    mappings = described_class.new(prison_number: 'A9127EK').call

    expect(mappings.first).to be_a(FrameworkNomisMapping)
  end

  it 'sets the correct attributes on framework NOMIS mappings' do
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    mappings = described_class.new(prison_number: 'A9127EK').call

    expect(mappings.first).to have_attributes(
      raw_nomis_mapping: nomis_alert,
      code_type: 'alert',
      code: 'XVL',
      code_description: 'Violent',
      comments: 'Some comment',
      creation_date: Date.parse('2013-03-29'),
      expiry_date: Date.parse('2100-06-08'),
    )
  end

  it 'ignores alerts that have expired' do
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert(expired: true)])
    mappings = described_class.new(prison_number: 'A9127EK').call

    expect(mappings).to be_empty
  end

  it 'ignores alerts that are not active' do
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert(active: false)])
    mappings = described_class.new(prison_number: 'A9127EK').call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if no prison number supplied' do
    allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
    mappings = described_class.new(prison_number: nil).call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if importing NOMIS alerts fails' do
    oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '')
    allow(NomisClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
    mappings = described_class.new(prison_number: 'A9127EK').call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if no alerts found for prison number' do
    allow(NomisClient::Alerts).to receive(:get).and_return([])
    mappings = described_class.new(prison_number: 'A9127EK').call

    expect(mappings).to be_empty
  end

  context 'with NOMIS sync status' do
    it 'sets the NOMIS sync status as successful if NOMIS client is successful' do
      allow(NomisClient::Alerts).to receive(:get).and_return([nomis_alert])
      mappings = described_class.new(prison_number: 'A9127EK')
      mappings.call

      expect(mappings.nomis_sync_status.status).to eq(FrameworkNomisMappings::NomisSyncStatus::SUCCESS)
    end

    it 'sets the NOMIS sync status as successful if NOMIS client is successful but no alerts returned' do
      allow(NomisClient::Alerts).to receive(:get).and_return([])
      mappings = described_class.new(prison_number: 'A9127EK')
      mappings.call

      expect(mappings.nomis_sync_status.status).to eq(FrameworkNomisMappings::NomisSyncStatus::SUCCESS)
    end

    it 'sets the NOMIS sync status as failed if NOMIS client throws an error' do
      oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '')
      allow(NomisClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
      mappings = described_class.new(prison_number: 'A9127EK')
      mappings.call

      expect(mappings.nomis_sync_status.status).to eq(FrameworkNomisMappings::NomisSyncStatus::FAILED)
    end

    it 'sets the NOMIS sync failure message if NOMIS client throws an error' do
      oauth2_response = instance_double('OAuth2::Response', body: '{"error": "BOOM"}', parsed: {}, status: '')
      allow(NomisClient::Alerts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
      mappings = described_class.new(prison_number: 'A9127EK')
      mappings.call

      expect(mappings.nomis_sync_status.message).to match(/BOOM/)
    end
  end

  def nomis_alert(expired: false, active: true)
    {
      alert_id: 2,
      alert_code: 'XVL',
      alert_code_description: 'Violent',
      comment: 'Some comment',
      created_at: '2013-03-29',
      expires_at: '2100-06-08',
      expired: expired,
      active: active,
      offender_no: 'A9127EK',
    }.with_indifferent_access
  end
end
