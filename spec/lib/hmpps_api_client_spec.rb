# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HmppsApiClient do
  describe '.dps_services_enabled?' do
    it 'defaults to true when ENABLE_DPS_SERVICES is not set' do
      ClimateControl.modify(ENABLE_DPS_SERVICES: nil) do
        expect(described_class.dps_services_enabled?).to be true
      end
    end

    it 'is true when ENABLE_DPS_SERVICES is "true"' do
      ClimateControl.modify(ENABLE_DPS_SERVICES: 'true') do
        expect(described_class.dps_services_enabled?).to be true
      end
    end

    it 'is false when ENABLE_DPS_SERVICES is "false"' do
      ClimateControl.modify(ENABLE_DPS_SERVICES: 'false') do
        expect(described_class.dps_services_enabled?).to be false
      end
    end
  end

  context 'when DPS services are disabled' do
    let(:booking_id) { 123 }
    let(:prison_number) { 'A1234AA' }
    let(:date) { Time.zone.today }

    around do |example|
      ClimateControl.modify(ENABLE_DPS_SERVICES: 'false') { example.run }
    end

    before do
      allow(OAuth2::Client).to receive(:new)
      allow(Rails.logger).to receive(:warn)
    end

    {
      'AlertsApiClient::AlertTypes.get' => [-> { AlertsApiClient::AlertTypes.get }, []],
      'AlertsApiClient::Alerts.get' => [-> { AlertsApiClient::Alerts.get(prison_number) }, []],
      'ManageUsersApiClient::UserEmail.get' => [-> { ManageUsersApiClient::UserEmail.get('USERNAME') }, nil],
      'PrisonerSearchApiClient::Prisoner.get' => [-> { PrisonerSearchApiClient::Prisoner.get(prison_number) }, nil],
      'PrisonerSearchApiClient::Prisoner.facial_image_exists?' => [-> { PrisonerSearchApiClient::Prisoner.facial_image_exists?(prison_number) }, false],
      'PrisonerSearchApiClient::LocationDescription.get' => [-> { PrisonerSearchApiClient::LocationDescription.get(prison_number) }, nil],
      'NomisClient::Activities.get' => [-> { NomisClient::Activities.get(booking_id, date, date) }, []],
      'NomisClient::Assessments.get' => [-> { NomisClient::Assessments.get(booking_id:) }, []],
      'NomisClient::BookingDetails.get' => [-> { NomisClient::BookingDetails.get(booking_id) }, { category: nil, category_code: nil, csra: nil }],
      'NomisClient::Contacts.get' => [-> { NomisClient::Contacts.get(booking_id:) }, []],
      'NomisClient::CourtCases.get' => [-> { NomisClient::CourtCases.get(booking_id) }, '[]'],
      'NomisClient::CourtHearings.get' => [-> { NomisClient::CourtHearings.get(booking_id, date, date) }, { 'hearings' => [] }],
      'NomisClient::CourtHearings.post' => [-> { NomisClient::CourtHearings.post(booking_id:, court_case_id: 1) }, nil],
      'NomisClient::Discharges.get' => [-> { NomisClient::Discharges.get(agency_id: 'PRI', date:) }, []],
      'NomisClient::Ethnicities.get' => [-> { NomisClient::Ethnicities.get }, []],
      'NomisClient::Genders.get' => [-> { NomisClient::Genders.get }, []],
      'NomisClient::Image.get' => [-> { NomisClient::Image.get(booking_id) }, nil],
      'NomisClient::LocationDetails.get' => [-> { NomisClient::LocationDetails.get }, {}],
      'NomisClient::Locations.get' => [-> { NomisClient::Locations.get }, []],
      'NomisClient::Movements.get' => [-> { NomisClient::Movements.get(agency_id: 'PRI', date:) }, {}],
      'NomisClient::PersonalCareNeeds.get' => [-> { NomisClient::PersonalCareNeeds.get(nomis_offender_numbers: [prison_number]) }, []],
      'NomisClient::ReasonableAdjustments.get' => [-> { NomisClient::ReasonableAdjustments.get(booking_id:, reasonable_adjustment_types: 'AA') }, []],
      'NomisClient::Rollcount.get' => [-> { NomisClient::Rollcount.get(agency_id: 'PRI') }, {}],
    }.each do |description, (call, expected)|
      describe description, :with_location_description_api do
        it 'returns an empty result' do
          expect(instance_exec(&call)).to eq(expected)
        end

        it 'does not attempt to get an auth token' do
          instance_exec(&call)
          expect(OAuth2::Client).not_to have_received(:new)
        end

        it 'logs a warning' do
          instance_exec(&call)
          expect(Rails.logger).to have_received(:warn).with(/not performing request/)
        end
      end
    end

    it 'raises rather than requesting a token if a client is called directly' do
      expect { NomisClient::Base.get('/foo') }.to raise_error(described_class::DpsServicesDisabledError)
      expect(OAuth2::Client).not_to have_received(:new)
    end
  end
end
