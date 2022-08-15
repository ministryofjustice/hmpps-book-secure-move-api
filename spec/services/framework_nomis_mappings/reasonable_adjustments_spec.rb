# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::ReasonableAdjustments do
  let(:nomis_codes) do
    [
      create(:framework_nomis_code, code: 'A', code_type: 'reasonable_adjustment'),
      create(:framework_nomis_code, code: 'C CB', code_type: 'reasonable_adjustment'),
    ]
  end

  it 'builds a framework NOMIS mapping for active reasonable adjustments from NOMIS' do
    allow(NomisClient::ReasonableAdjustments)
      .to receive(:get)
      .with(booking_id: 111_111, reasonable_adjustment_types: 'A,C CB')
      .and_return([nomis_reasonable_adjustment])
    mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes).call

    expect(mappings.first).to be_a(FrameworkNomisMapping)
  end

  it 'sets the correct attributes on framework NOMIS mappings' do
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([nomis_reasonable_adjustment])
    mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes).call

    expect(mappings.first).to have_attributes(
      raw_nomis_mapping: nomis_reasonable_adjustment,
      code_type: 'reasonable_adjustment',
      code: 'DA',
      code_description: 'Some treatment description about DA',
      comments: 'Some comment',
      start_date: Date.parse('2010-06-21'),
      end_date: Date.parse('2100-06-21'),
    )
  end

  it 'imports reasonable adjustments if end date is not set' do
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([nomis_reasonable_adjustment])
    mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes).call

    expect(mappings.count).to eq(1)
  end

  it 'ignores reasonable adjustments that have ended' do
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([nomis_reasonable_adjustment(end_date: '2010-06-21')])
    mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes).call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if no booking id supplied' do
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([nomis_reasonable_adjustment])
    mappings = described_class.new(booking_id: nil, nomis_codes: ['A', 'C CB']).call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if no reasonable adjustment types supplied' do
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([nomis_reasonable_adjustment])
    mappings = described_class.new(booking_id: 1_111_111, nomis_codes: []).call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if importing NOMIS reasonable adjustments fails' do
    oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '')
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
    mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes).call

    expect(mappings).to be_empty
  end

  it 'returns an empty result if no reasonable adjustments found for booking id' do
    allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([])
    mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes).call

    expect(mappings).to be_empty
  end

  context 'with NOMIS sync status' do
    it 'sets the NOMIS sync status as successful if NOMIS client is successful' do
      allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([nomis_reasonable_adjustment])
      mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes)
      mappings.call

      expect(mappings.nomis_sync_status.status).to eq(FrameworkNomisMappings::NomisSyncStatus::SUCCESS)
    end

    it 'sets the NOMIS sync status as successful if NOMIS client is successful but no personal care needs returned' do
      allow(NomisClient::ReasonableAdjustments).to receive(:get).and_return([])
      mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes)
      mappings.call

      expect(mappings.nomis_sync_status.status).to eq(FrameworkNomisMappings::NomisSyncStatus::SUCCESS)
    end

    it 'sets the NOMIS sync status as failed if NOMIS client throws an error' do
      oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '')
      allow(NomisClient::ReasonableAdjustments).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
      mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes)
      mappings.call

      expect(mappings.nomis_sync_status.status).to eq(FrameworkNomisMappings::NomisSyncStatus::FAILED)
    end

    it 'sets the NOMIS sync failure message if NOMIS client throws an error' do
      oauth2_response = instance_double('OAuth2::Response', body: '{"error": "BOOM"}', parsed: {}, status: '')
      allow(NomisClient::ReasonableAdjustments).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
      mappings = described_class.new(booking_id: 111_111, nomis_codes: nomis_codes)
      mappings.call

      expect(mappings.nomis_sync_status.message).to match(/BOOM/)
    end
  end

  def nomis_reasonable_adjustment(start_date: '2010-06-21', end_date: '2100-06-21')
    {
      treatment_code: 'DA',
      comment_text: 'Some comment',
      start_date: start_date,
      end_date: end_date,
      agency_id: 'LGI',
      treatment_description: 'Some treatment description about DA',
    }.with_indifferent_access
  end
end
