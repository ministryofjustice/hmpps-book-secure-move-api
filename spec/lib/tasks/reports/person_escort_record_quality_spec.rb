# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['reports:person_escort_record_quality'] do
  before do
    allow(Reports::PersonEscortRecordQuality).to receive(:call)

    described_class.reenable
  end

  context 'without a start date' do
    it 'raises an error' do
      expect { described_class.invoke }.to raise_error(KeyError)
    end
  end

  context 'with a start date' do
    it 'parses the date and passes it to the report' do
      described_class.invoke('2020-01-01')

      expect(Reports::PersonEscortRecordQuality)
        .to have_received(:call).with(start_date: Date.new(2020, 1, 1), end_date: nil)
    end

    context 'with an end date' do
      it 'parses the date and passes it to the report' do
        described_class.invoke('2020-01-01', '2021-01-01')

        expect(Reports::PersonEscortRecordQuality)
          .to have_received(:call).with(start_date: Date.new(2020, 1, 1), end_date: Date.new(2021, 1, 1))
      end
    end
  end
end
