require 'rails_helper'

RSpec.describe AccessLog, type: :model do
  describe 'http verb' do
    it 'validates presence of `verb`' do
      expect(build(:access_log)).to(validate_presence_of(:verb))
    end

    context 'when a GET request is made' do
      let(:access_log) { build(:access_log, :get) }

      it 'validates `verb` is set' do
        expect(access_log.verb).to eq('GET')
      end
    end

    context 'when a PUT request is made' do
      let(:access_log) { build(:access_log, :put) }

      it 'validates `verb` is set' do
        expect(access_log.verb).to eq('PUT')
      end
    end

    context 'when a POST request is made' do
      let(:access_log) { build(:access_log, :post) }

      it 'validates `verb` is set' do
        expect(access_log.verb).to eq('POST')
      end
    end

    context 'when a DELETE request is made' do
      let(:access_log) { build(:access_log, :delete) }

      it 'validates `verb` is set' do
        expect(access_log.verb).to eq('DELETE')
      end
    end

    context 'when a HEAD request is made' do
      let(:access_log) { build(:access_log, :head) }

      it 'validates `verb` is set' do
        expect(access_log.verb).to eq('HEAD')
      end
    end
  end
end
