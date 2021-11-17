# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::Results do
  subject(:results) { described_class.new }

  describe '#total' do
    subject(:total) { results.total }

    context 'without any records' do
      it { is_expected.to eq(0) }
    end

    context 'with a success recorded' do
      before { results.record_success({ id: 0 }) }

      it { is_expected.to eq(1) }
    end

    context 'with a failure recorded' do
      before { results.record_failure({ id: 1 }, reason: 'Reason') }

      it { is_expected.to eq(1) }
    end

    context 'with a success and a failure recorded' do
      before do
        results.record_success({ id: 0 })
        results.record_failure({ id: 1 }, reason: 'Reason')
      end

      it { is_expected.to eq(2) }
    end
  end

  describe '#save' do
    let(:obj) { double }
    let(:record) { { id: 1 } }

    context 'when save is successful' do
      before { allow(obj).to receive(:save).and_return(true) }

      it 'records a successful record' do
        return_value = results.save(obj, record)

        expect(return_value).to be(true)
        expect(results.successes).to match_array([record])
        expect(results.failures).to be_empty
      end
    end

    context 'when save is not successful' do
      before { allow(obj).to receive(:save).and_return(false) }

      it 'records a failed record' do
        return_value = results.save(obj, record)

        expect(return_value).to be(false)
        expect(results.successes).to be_empty
        expect(results.failures).to match_array([record.merge(reason: 'Could not save record.')])
      end
    end
  end

  describe '#ensure_valid' do
    let(:obj) { double }
    let(:record) { { id: 1 } }

    context 'when object is valid' do
      before { allow(obj).to receive(:valid?).and_return(true) }

      it 'does not record a result' do
        return_value = results.ensure_valid(obj, record)

        expect(return_value).to be(true)
        expect(results.successes).to be_empty
        expect(results.failures).to be_empty
      end
    end

    context 'when object is not valid' do
      before { allow(obj).to receive(:valid?).and_return(false) }

      it 'records a failed record' do
        return_value = results.ensure_valid(obj, record)

        expect(return_value).to be(false)
        expect(results.successes).to be_empty
        expect(results.failures).to match_array([record.merge(reason: 'Record is not valid.')])
      end
    end
  end

  describe '#summary' do
    subject(:summary) { results.summary }

    context 'without any records' do
      it { is_expected.to eq("Imported 0 records with 0 failures.\n") }
    end

    context 'with a success recorded' do
      before { results.record_success({ id: 0 }) }

      it { is_expected.to eq("Imported 1 records with 0 failures.\n") }
    end

    context 'with a failure recorded' do
      before { results.record_failure({ id: 1 }, reason: 'Reason') }

      it { is_expected.to eq("Imported 1 records with 1 failures.\n\nid,reason\n1,Reason\n") }
    end

    context 'with a success and a failure recorded' do
      before do
        results.record_success({ id: 0 })
        results.record_failure({ id: 1 }, reason: 'Reason')
      end

      it { is_expected.to eq("Imported 2 records with 1 failures.\n\nid,reason\n1,Reason\n") }
    end
  end
end
