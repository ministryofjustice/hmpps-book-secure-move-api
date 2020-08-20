# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::People do
  describe '.get', with_nomis_client_authentication: true do
    let(:prison_numbers) { %w[G3239GV GV345VG G3325XX] }

    context 'when resources are found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/post_prisoners_200.json').read }

      it 'returns the correct people data' do
        described_class.get(prison_numbers)
      end
    end
  end
end
