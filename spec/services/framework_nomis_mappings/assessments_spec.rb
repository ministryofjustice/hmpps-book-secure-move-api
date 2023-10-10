# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::Assessments do
  subject(:mappings) { described_class.new(booking_id:, nomis_sync_status:).call }

  let(:nomis_sync_status) { FrameworkNomisMappings::NomisSyncStatus.new(resource_type: 'assessments') }

  shared_examples 'successful sync status' do
    it 'sets the sync status to success' do
      subject
      expect(nomis_sync_status.is_success?).to be(true)
    end
  end

  shared_examples 'failed sync status' do
    it 'sets the sync status to failure' do
      subject
      expect(nomis_sync_status.is_failure?).to be(true)
    end
  end

  context 'without a booking ID' do
    let(:booking_id) { nil }

    it 'returns no mappings' do
      expect(mappings).to be_empty
    end
  end

  context 'with a booking ID' do
    let(:booking_id) { 111_111 }

    context 'when the request succeeds' do
      before do
        allow(NomisClient::Assessments).to receive(:get).and_return(nomis_assessments)
      end

      context 'without any NOMIS assessments' do
        let(:nomis_assessments) { [] }

        it 'returns no mappings' do
          expect(mappings).to be_empty
        end

        it_behaves_like 'successful sync status'
      end

      context 'with a valid NOMIS assessment' do
        let(:nomis_assessments) { [nomis_assessment] }

        it 'returns a framework NOMIS mapping' do
          expect(mappings.first).to be_a(FrameworkNomisMapping)
        end

        it_behaves_like 'successful sync status'

        it 'sets the correct attributes on the framework NOMIS mapping' do
          expect(mappings.first).to have_attributes(
            raw_nomis_mapping: nomis_assessments.first,
            code_type: 'assessment',
            code: 'CSR',
            code_description: 'Cell Share Risk Assessment',
            comments: 'Standard',
            approval_date: Date.parse('2010-06-21'),
            next_review_date: Date.parse('2100-06-21'),
          )
        end

        context 'with a comment' do
          let(:nomis_assessments) { [nomis_assessment(comment: 'this is a comment')] }

          it 'includes the comment' do
            expect(mappings.first.comments).to eq('Standard — this is a comment')
          end
        end

        context 'without a next review date' do
          let(:nomis_assessments) { [nomis_assessment(next_review_date: nil)] }

          it 'is returned' do
            expect(mappings).not_to be_empty
          end
        end

        context 'without a classification' do
          let(:nomis_assessments) { [nomis_assessment(classification: nil)] }

          it 'is returned' do
            expect(mappings.first.comments).to eq('')
          end
        end
      end

      context 'with an out-of-date assessment' do
        let(:nomis_assessments) { [nomis_assessment(next_review_date: '2001-01-01')] }

        it 'returns no mappings' do
          expect(mappings).to be_empty
        end

        it_behaves_like 'successful sync status'
      end
    end

    context 'when the request fails' do
      before do
        oauth2_response = instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '')
        allow(NomisClient::Assessments).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
      end

      it 'returns no mappings' do
        expect(mappings).to be_empty
      end

      it_behaves_like 'failed sync status'
    end
  end

  def nomis_assessment(approval_date: '2010-06-21', next_review_date: '2100-06-21', classification: 'Standard', comment: '')
    {
      assessment_code: 'CSR',
      assessment_description: 'Cell Share Risk Assessment',
      assessment_comment: comment,
      classification:,
      approval_date:,
      next_review_date:,
      offender_no: '321',
    }.with_indifferent_access
  end
end
