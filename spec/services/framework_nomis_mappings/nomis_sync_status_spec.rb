# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::NomisSyncStatus do
  describe '#set_success' do
    it 'sets the `status` as "success"' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')
      nomis_sync_status.set_success

      expect(nomis_sync_status.status).to eq(described_class::SUCCESS)
    end

    it 'sets the `synced_at` timestamp' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')
      sync_at_timstamp = Time.zone.now
      allow(Time).to receive(:now).and_return(sync_at_timstamp)
      nomis_sync_status.set_success

      expect(nomis_sync_status.synced_at).to eq(sync_at_timstamp)
    end
  end

  describe '#set_failure' do
    it 'sets the `status` as "failed"' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')
      nomis_sync_status.set_failure

      expect(nomis_sync_status.status).to eq(described_class::FAILED)
    end

    it 'sets the `synced_at` timestamp' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')
      sync_at_timstamp = Time.zone.now
      allow(Time).to receive(:now).and_return(sync_at_timstamp)
      nomis_sync_status.set_failure

      expect(nomis_sync_status.synced_at).to eq(sync_at_timstamp)
    end

    it 'sets the error `message`' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')
      nomis_sync_status.set_failure(message: 'BOOM!')

      expect(nomis_sync_status.message).to eq('BOOM!')
    end
  end

  describe '#as_json' do
    it 'returns the attributes of nomis sync status as json' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')

      expect(nomis_sync_status.as_json).to eq(
        resource_type: 'some_resource',
        status: nil,
        synced_at: nil,
        message: nil,
      )
    end

    it 'returns the attributes of nomis sync status if set as json' do
      nomis_sync_status = described_class.new(resource_type: 'some_resource')
      sync_at_timstamp = Time.zone.now
      allow(Time).to receive(:now).and_return(sync_at_timstamp)
      nomis_sync_status.set_success

      expect(nomis_sync_status.as_json).to eq(
        resource_type: 'some_resource',
        status: described_class::SUCCESS,
        synced_at: sync_at_timstamp,
        message: nil,
      )
    end
  end
end
