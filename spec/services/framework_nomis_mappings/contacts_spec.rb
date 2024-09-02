# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappings::Contacts do
  subject(:mappings) { described_class.new(booking_id:, nomis_sync_status:).call }

  let(:nomis_sync_status) { FrameworkNomisMappings::NomisSyncStatus.new(resource_type: 'contacts') }

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
        allow(NomisClient::Contacts).to receive(:get).and_return(nomis_contacts)
      end

      context 'without any NOMIS assessments' do
        let(:nomis_contacts) { [] }

        it 'returns no mappings' do
          expect(mappings).to be_empty
        end

        it_behaves_like 'successful sync status'
      end

      context 'with a valid NOMIS assessment' do
        let(:nomis_contacts) { [nomis_contact] }

        it 'returns a framework NOMIS mapping' do
          expect(mappings.first).to be_a(FrameworkNomisMapping)
        end

        it_behaves_like 'successful sync status'

        it 'sets the correct attributes on the framework NOMIS mapping' do
          expect(mappings.first).to have_attributes(
            raw_nomis_mapping: nomis_contacts.first,
            code_type: 'contact',
            code: 'NEXTOFKIN',
            code_description: 'Next of Kin',
            comments: 'First Middle Last',
            creation_date: Date.parse('2020-01-01'),
            expiry_date: Date.parse('2100-01-01'),
          )
        end

        context 'with a comment' do
          let(:nomis_contacts) { [nomis_contact(comment: 'Comment')] }

          it 'includes the comment' do
            expect(mappings.first.comments).to eq('First Middle Last — Comment')
          end
        end

        context 'with a relationship' do
          let(:nomis_contacts) { [nomis_contact(relationship: 'Relationship')] }

          it 'includes the relationship' do
            expect(mappings.first.comments).to eq('First Middle Last — Relationship')
          end
        end
      end

      context 'with a non next of kin contact' do
        let(:nomis_contacts) { [nomis_contact(next_of_kin: false)] }

        it 'returns no mappings' do
          expect(mappings.first.code).to eq('OTHER')
        end

        it_behaves_like 'successful sync status'
      end

      context 'with an inactive contact' do
        let(:nomis_contacts) { [nomis_contact(active: false)] }

        it 'returns no mappings' do
          expect(mappings).to be_empty
        end

        it_behaves_like 'successful sync status'
      end
    end

    context 'when the request fails' do
      before do
        oauth2_response = instance_double(OAuth2::Response, body: '{}', parsed: {}, status: '')
        allow(NomisClient::Contacts).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
      end

      it 'returns no mappings' do
        expect(mappings).to be_empty
      end

      it_behaves_like 'failed sync status'
    end
  end

  def nomis_contact(active: true, next_of_kin: true, relationship: nil, comment: nil)
    {
      active_flag: active,
      next_of_kin:,
      create_date_time: '2020-01-01',
      expiry_date: '2100-01-01',
      first_name: 'First',
      middle_name: 'Middle',
      last_name: 'Last',
      relationship_description: relationship,
      comment_text: comment,
    }.with_indifferent_access
  end
end
