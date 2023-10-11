# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::NomisSyncStatus do
  subject(:nomis_sync_status) { described_class.new(resource_type: 'some_resource') }

  let(:sync_date) { Time.zone.local(2020, 1, 1) }

  describe '#set_success' do
    before do
      travel_to(sync_date) { nomis_sync_status.set_success }
    end

    it 'sets the status to success' do
      expect(nomis_sync_status.status).to eq(described_class::SUCCESS)
    end

    it 'sets the synced_at timestamp' do
      expect(nomis_sync_status.synced_at).to eq(sync_date)
    end

    it 'is marked as a success' do
      expect(nomis_sync_status.is_success?).to be(true)
      expect(nomis_sync_status.is_failure?).to be(false)
    end
  end

  describe '#set_failure' do
    let(:message) { nil }

    before do
      travel_to(sync_date) { nomis_sync_status.set_failure(message:) }
    end

    it 'sets the status to success' do
      expect(nomis_sync_status.status).to eq(described_class::FAILED)
    end

    it 'sets the synced_at timestamp' do
      expect(nomis_sync_status.synced_at).to eq(sync_date)
    end

    it 'is marked as a failure' do
      expect(nomis_sync_status.is_failure?).to be(true)
      expect(nomis_sync_status.is_success?).to be(false)
    end

    context 'with a message' do
      let(:message) { 'Boom!' }

      it 'sets the error message' do
        expect(nomis_sync_status.message).to eq('Boom!')
      end
    end
  end

  describe '#as_json' do
    it 'returns the attributes of nomis sync status as json' do
      expect(nomis_sync_status.as_json).to eq(
        resource_type: 'some_resource',
        status: nil,
        synced_at: nil,
        message: nil,
      )
    end

    context 'with a success' do
      before do
        travel_to(sync_date) { nomis_sync_status.set_success }
      end

      it 'returns the attributes of nomis sync status if set as json' do
        expect(nomis_sync_status.as_json).to eq(
          resource_type: 'some_resource',
          status: described_class::SUCCESS,
          synced_at: sync_date,
          message: nil,
        )
      end
    end
  end
end
