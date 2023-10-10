# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ProfilesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:risk_type_1) { create :assessment_question, :risk }
  let(:risk_type_2) { create :assessment_question, :risk }

  describe 'PATCH /v1/people/:id/profiles' do
    let(:schema) { load_yaml_schema('patch_profiles_responses.yaml', version: 'v1') }

    let(:profile_params) do
      {
        data: {
          type: 'profiles',
          attributes: {
            assessment_answers: [
              { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
              { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
            ],
          },
        },
      }
    end

    let(:expected_data) do
      {
        type: 'profiles',
        attributes: {
          assessment_answers: [
            { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
            { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
          ],
        },
      }
    end
    let(:profile) { create(:profile, documents: before_documents) }
    let(:before_documents) { create_list(:document, 2) }

    context 'with no pre-existing assessment_answers on profile' do
      before do
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'adds assessment_answers to the profile' do
        expect(profile.reload.assessment_answers.map(&:assessment_question_id)).to contain_exactly(risk_type_1.id, risk_type_2.id)
      end

      it 'returns the correct data' do
        expect(response_json['data']).to include_json(expected_data)
      end
    end

    context 'with pre-existing assessment_answers on profile' do
      let(:profile) { create(:profile, assessment_answers: [{ title: risk_type_1.title, assessment_question_id: risk_type_1.id }]) }
      let(:profile_params) do
        {
          data: {
            type: 'profiles',
            attributes: {
              assessment_answers: [
                { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
              ],
            },
          },
        }
      end

      let(:expected_data) do
        {
          type: 'profiles',
          attributes: {
            assessment_answers: [
              { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
            ],
          },
        }
      end

      before do
        allow(Notifier).to receive(:prepare_notifications)
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the assessment_answers on the profile' do
        expect(profile.reload.assessment_answers.map(&:assessment_question_id)).to contain_exactly(risk_type_2.id)
      end

      it 'returns the correct data' do
        expect(response_json['data']).to include_json(expected_data)
      end

      it 'calls the notifier' do
        expect(Notifier).to have_received(:prepare_notifications).with(topic: profile, action_name: 'update')
      end
    end

    context 'when updating Profile documents' do
      let(:after_documents) { create_list(:document, 2) }
      let(:profile_params) do
        documents = after_documents.map { |d| { id: d.id, type: 'documents' } }
        {
          data: {
            type: 'profiles',
            relationships: { documents: { data: documents } },
          },
        }
      end

      it 'updates the profiles documents' do
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json

        expect(profile.reload.documents).to match_array(after_documents)
      end

      it 'does not affect other relationships' do
        expect { patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json }
          .not_to(change { profile.reload.person })
      end

      it 'returns the updated documents in the response body' do
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json

        expect(
          response_json.dig('data', 'relationships', 'documents', 'data').map { |document| document['id'] },
        ).to match_array(after_documents.pluck(:id))
      end

      context 'when documents is an empty array' do
        let(:profile_params) do
          {
            data: {
              type: 'profiles',
              relationships: { documents: { data: [] } },
            },
          }
        end

        it 'removes the documents from the move' do
          expect(profile.documents).to match_array(before_documents)

          patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json

          expect(profile.reload.documents).to match_array([])
        end
      end

      context 'when documents are nil' do
        let(:profile_params) do
          {
            type: 'profiles',
            relationships: { documents: { data: nil } },
          }
        end

        it 'does not remove documents from the profile' do
          patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json

          expect(profile.reload.documents).to match_array(before_documents)
        end
      end
    end

    context 'with included relationships' do
      let(:profile_params) do
        {
          include: include_params,
          data: {
            type: 'profiles',
            attributes: {
              assessment_answers: [
                { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
                { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
              ],
            },
          },
        }
      end

      before do
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json
      end

      context 'when the include query param is empty' do
        let(:include_params) { [] }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when include is nil' do
        let(:include_params) { nil }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including a relationship' do
        let(:include_params) { 'person' }

        it 'includes the relevant relationships' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq

          expect(returned_types).to contain_exactly('people')
        end
      end

      context 'when including a non existing relationship in a query param' do
        let(:include_params) { 'person,non-existent-relationship' }

        it 'responds with error 400' do
          response_error = response_json['errors'].first

          expect(response_error['title']).to eq('Bad request')
          expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
        end
      end
    end

    context 'when updating requires_youth_risk_assessment' do
      let(:profile) { create(:profile) }
      let(:profile_params) do
        {
          data: {
            type: 'profiles',
            attributes: {
              requires_youth_risk_assessment: true,
            },
          },
        }
      end

      let(:expected_data) do
        {
          type: 'profiles',
          attributes: {
            requires_youth_risk_assessment: true,
          },
        }
      end

      before do
        allow(Notifier).to receive(:prepare_notifications)
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'updates the assessment_answers on the profile' do
        expect(profile.reload.requires_youth_risk_assessment).to eq(true)
      end

      it 'returns the correct data' do
        expect(response_json['data']).to include_json(expected_data)
      end

      it 'calls the notifier' do
        expect(Notifier).to have_received(:prepare_notifications).with(topic: profile, action_name: 'update')
      end
    end

    context 'with a bad request' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }
      let(:profile_params) { nil }

      before do
        patch "/api/v1/people/#{profile.person.id}/profiles/#{profile.id}", params: profile_params, headers:, as: :json
      end

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when the profile_id is not found' do
      let(:move_id) { 'foo-bar' }
      let(:detail_404) { "Couldn't find Profile with 'id'=foo-bar" }

      before { patch "/api/v1/people/#{profile.person.id}/profiles/foo-bar", params: profile_params, headers:, as: :json }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'when the person_id is not found' do
      before { patch "/api/v1/people/foo-bar/profiles/#{profile.id}", params: profile_params, headers:, as: :json }

      let(:detail_404) { "Couldn't find Person with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
