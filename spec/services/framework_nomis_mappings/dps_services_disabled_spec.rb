# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FrameworkNomisMappings when DPS services are disabled' do
  around do |example|
    ClimateControl.modify(ENABLE_DPS_SERVICES: 'false') { example.run }
  end

  before do
    allow(OAuth2::Client).to receive(:new)
  end

  {
    'alerts' => -> { FrameworkNomisMappings::Alerts.new(prison_number: 'A9127EK', nomis_sync_status: status) },
    'assessments' => -> { FrameworkNomisMappings::Assessments.new(booking_id: 123, nomis_sync_status: status) },
    'contacts' => -> { FrameworkNomisMappings::Contacts.new(booking_id: 123, nomis_sync_status: status) },
    'personal care needs' => -> { FrameworkNomisMappings::PersonalCareNeeds.new(prison_number: 'A9127EK', nomis_sync_status: status) },
    'reasonable adjustments' => -> { FrameworkNomisMappings::ReasonableAdjustments.new(booking_id: 123, nomis_codes: [{ code: 'AA' }], nomis_sync_status: status) },
  }.each do |resource, build|
    context "with #{resource}" do
      let(:status) { FrameworkNomisMappings::NomisSyncStatus.new(resource_type: resource) }

      it 'returns no mappings, records a sync failure and does not request a token' do
        expect(instance_exec(&build).call).to eq([])
        expect(status).to be_is_failure
        expect(status.message).to eq(HmppsApiClient::DPS_SERVICES_DISABLED_MESSAGE)
        expect(OAuth2::Client).not_to have_received(:new)
      end
    end
  end
end
