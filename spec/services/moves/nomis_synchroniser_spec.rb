# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::NomisSynchroniser do
  subject(:synchroniser) do
    described_class.new(
      locations: [location],
      date: date
    )
  end

  let(:date) { Date.today }

  describe '.call' do
    let(:importer) { instance_double(Moves::Importer, call: nil) }
    let(:sweeper) { instance_double(Moves::Sweeper, call: nil) }

    before do
      allow(Moves::Importer).to receive(:new).and_return(importer)
      allow(Moves::Sweeper).to receive(:new).and_return(sweeper)
      allow(NomisClient::Moves).to receive(:get).and_return([])
      synchroniser.call
    end

    context 'when the location is a police custody unit' do
      let(:location) { build :location, :police }

      it 'does NOT call importer' do
        expect(Moves::Importer).not_to have_received(:new)
      end

      it 'does NOT call sweeper' do
        expect(Moves::Sweeper).not_to have_received(:new)
      end

      it 'does NOT call the NOMIS API' do
        expect(NomisClient::Moves).not_to have_received(:get)
      end
    end

    context 'when the location is a prison' do
      let(:location) { build :location }

      it 'calls importer' do
        expect(Moves::Importer).to have_received(:new).with([])
      end

      it 'calls sweeper' do
        expect(Moves::Sweeper).to have_received(:new).with(location, date, [])
      end

      it 'calls the NOMIS API' do
        expect(NomisClient::Moves).to have_received(:get)
      end
    end
  end
end
