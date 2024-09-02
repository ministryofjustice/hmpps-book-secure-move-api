# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::People do
  describe '.get', :with_nomis_client_authentication do
    let(:prison_numbers) { %w[G3239GV GV345VG G3325XX] }

    context 'when resources are found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/post_prisoners_200.json').read }

      it 'returns the correct people data' do
        expect(described_class.get(prison_numbers)).to eq([
          {
            aliases: nil,
            cro_number: '018053/82G',
            date_of_birth: '1965-10-15',
            ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
            first_name: 'AVEILKE',
            gender: 'M',
            last_name: 'ABBELLA',
            latest_booking_id: 20_305,
            middle_names: 'EMMANDA',
            nationalities: 'British',
            pnc_number: '82/18053V',
            prison_number: 'G3239GV',
          },
          {
            aliases: nil,
            cro_number: '018053/82G',
            date_of_birth: '1965-10-15',
            ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
            first_name: 'AVEILKE',
            gender: 'M',
            last_name: 'ABBELLA',
            latest_booking_id: 20_305,
            middle_names: 'EMMANDA',
            nationalities: 'British',
            pnc_number: '82/18053V',
            prison_number: 'GV345VG',
          },
          {
            aliases: nil,
            cro_number: '018053/82G',
            date_of_birth: '1965-10-15',
            ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
            first_name: 'AVEILKE',
            gender: 'M',
            last_name: 'ABBELLA',
            latest_booking_id: 20_305,
            middle_names: 'EMMANDA',
            nationalities: 'British',
            pnc_number: '82/18053V',
            prison_number: 'G3325XX',
          },
        ])
      end
    end
  end
end
