# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Contacts, :with_hmpps_authentication do
  describe '#get' do
    subject(:response) { described_class.get(booking_id:) }

    let(:booking_id) { 321 }

    context 'with a non-empty body' do
      let(:response_body) { file_fixture('nomis/get_contacts_200.json').read }

      let(:client_response) do
        [
          {
            active_flag: true,
            approved_visitor_flag: true,
            aware_of_charges_flag: true,
            booking_id: 2_468_081,
            can_be_contacted_flag: false,
            comment_text: 'Some additional information',
            contact_root_offender_id: 5_871_791,
            contact_type: 'O',
            contact_type_description: 'Official',
            create_date_time: '2021-10-13T07:06:12.199Z',
            emergency_contact: true,
            expiry_date: '2019-01-31T00:00:00.000+00:00',
            first_name: 'JOHN',
            last_name: 'SMITH',
            middle_name: 'MARK',
            next_of_kin: true,
            person_id: 5_871_791,
            relationship: 'RO',
            relationship_description: 'Responsible Officer',
            relationship_id: 10_466_277,
          },
          {
            active_flag: true,
            approved_visitor_flag: true,
            aware_of_charges_flag: true,
            booking_id: 2_468_081,
            can_be_contacted_flag: false,
            comment_text: 'Some additional information',
            contact_root_offender_id: 5_871_791,
            contact_type: 'O',
            contact_type_description: 'Official',
            create_date_time: '2021-10-13T07:06:12.199Z',
            emergency_contact: true,
            expiry_date: '2019-01-31T00:00:00.000+00:00',
            first_name: 'JOHN',
            last_name: 'SMITH',
            middle_name: 'MARK',
            next_of_kin: false,
            person_id: 5_871_791,
            relationship: 'RO',
            relationship_description: 'Responsible Officer',
            relationship_id: 10_466_277,
          },
        ]
      end

      it 'returns the correct person data' do
        expect(response).to eq(client_response)
      end
    end

    context 'with an empty response body' do
      let(:response_body) { {}.to_json }

      it 'returns an empty array' do
        expect(response).to be_empty
      end
    end
  end
end
