# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Assessments, :with_nomis_client_authentication do
  describe '#get' do
    subject(:response) { described_class.get(booking_id:) }

    let(:booking_id) { 321 }

    context 'with a non-empty body' do
      let(:response_body) { file_fixture('nomis/get_assessments_200.json').read }

      let(:client_response) do
        [
          {
            approval_date: '2017-04-14',
            assessment_code: 'CSR',
            assessment_comment: 'Assess comment text 1',
            assessment_date: '2017-04-02',
            assessment_description: 'CSR Rating',
            assessment_seq: 1,
            assessment_status: 'A',
            assessor_id: -1,
            assessor_user: 'User1',
            booking_id: -4,
            cell_sharing_alert_flag: true,
            classification: 'Medium',
            classification_code: 'MED',
            next_review_date: '2018-06-04',
            offender_no: 'A1234AD',
          },
          {
            approval_date: '2016-04-17',
            assessment_code: 'CATEGORY',
            assessment_comment: 'Assess comment text 2',
            assessment_date: '2016-03-04',
            assessment_description: 'Categorisation',
            assessment_seq: 2,
            assessment_status: 'I',
            assessor_id: -2,
            assessor_user: 'User2',
            booking_id: -4,
            cell_sharing_alert_flag: false,
            classification: 'Unclass',
            classification_code: 'Z',
            next_review_date: '2016-05-07',
            offender_no: 'A1234AD',
          },
          {
            approval_date: '2016-04-18',
            assessment_code: 'CATEGORY',
            assessment_comment: 'Assess comment text 3',
            assessment_date: '2016-04-04',
            assessment_description: 'Categorisation',
            assessment_seq: 3,
            assessment_status: 'A',
            assessor_id: -3,
            assessor_user: 'User3',
            booking_id: -4,
            cell_sharing_alert_flag: false,
            classification: 'Unsentenced',
            classification_code: 'U',
            next_review_date: '2016-06-08',
            offender_no: 'A1234AD',
          },
        ]
      end

      it 'returns the correct person data' do
        expect(response).to eq(client_response)
      end
    end

    context 'with an empty response body' do
      let(:response_body) { [].to_json }

      it 'returns an empty array' do
        expect(response).to be_empty
      end
    end
  end
end
