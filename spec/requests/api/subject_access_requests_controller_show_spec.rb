# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectAccessRequestsController do
  describe 'GET /subject-access-request' do
    subject(:get_sar) { get '/subject-access-request', params:, headers: }

    let(:schema) { load_yaml_schema('get_subject_access_request_responses.yaml') }
    let(:params) { {} }
    let(:application) { Doorkeeper::Application.create(name: 'test') }
    let(:token_payload) { { 'scope' => 'read', 'authorities' => %w[ROLE_SAR_DATA_ACCESS] } }
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => 'Bearer blahblah') }
    let(:response_json) { JSON.parse(response.body) }
    let(:content_type) { ApiController::CONTENT_TYPE }

    before do
      allow(JwksDecoder).to receive(:decode_token).and_return([token_payload])
    end

    context 'when the token is invalid' do
      let(:token_payload) { {} }

      before do
        get_sar
      end

      it 'returns a response object with status 401' do
        expect(response.status).to eq 401
      end
    end

    context 'when the token is missing the ROLE_SAR_DATA_ACCESS role' do
      before do
        token_payload['authorities'] = ['']
        get_sar
      end

      it 'returns a response object with status 403' do
        expect(response.status).to eq 403
      end
    end

    context 'when the token has the ROLE_SAR_DATA_ACCESS scope' do
      context 'when a crn is provided' do
        let(:params) { { crn: 'test' } }

        before do
          get_sar
        end

        it 'returns a response object with status 209' do
          expect(response.status).to eq 209
        end
      end

      context 'when a prn is provided' do
        let(:params) { { prn: 'test' } }

        context 'when no Person is found matching the identifier' do
          before do
            get_sar
          end

          it 'returns a response object with status 204' do
            expect(response.status).to eq 204
          end
        end

        context 'when 1 Person is found matching the identifier' do
          let!(:person) { create(:person_without_profiles, prison_number: 'test') }
          let!(:events) { [create(:event_person_move_assault, eventable: person), create(:event_person_move_road_traffic_accident, eventable: person), create(:event_person_move_released_error, eventable: person)] }
          let!(:per_profile) { create(:profile, :with_person_escort_record_with_responses, :with_documents, person:) }
          let!(:yra_profile) { create(:profile, :with_youth_risk_assessment_with_responses, person:) }
          let(:profiles) { person.profiles }
          let!(:pers_events) { [create(:event_per_completion, eventable: per_profile.person_escort_record), create(:event_per_generic, eventable: per_profile.person_escort_record)] }
          let!(:moves) { [create(:move, profile: per_profile), create(:move, profile: per_profile), create(:move, profile: yra_profile)] }
          let!(:moves_events) { [create(:event_move_accept, eventable: moves.first), create(:event_move_complete, eventable: moves.last)] }
          let!(:court_hearings) { [create(:court_hearing, move: moves.first), create(:court_hearing, move: moves.first), create(:court_hearing, move: moves.last)] }
          let!(:journeys) { [create(:journey, move: moves.first), create(:journey, move: moves.last)] }
          let!(:journeys_events) { [create(:event_journey_create, eventable: journeys.first), create(:event_journey_admit_to_reception, eventable: journeys.last)] }
          let(:person_hash) { JSON.parse(response.body, symbolize_names: true).dig(:content, 0, :data) }
          let(:relationships_hash) { person_hash[:relationships] }
          let(:ethnicity_hash) { relationships_hash[:ethnicity] }
          let(:gender_hash) { relationships_hash[:gender] }
          let(:events_hash) { relationships_hash[:events] }
          let(:moves_hash) { relationships_hash[:moves] }
          let(:journeys_hash) { moves_hash.flat_map { _1.dig(:data, :relationships, :journeys) } }
          let(:profiles_hash) { relationships_hash[:profiles] }

          before do
            get_sar
          end

          it 'returns a response object with status 200' do
            expect(response.status).to eq 200
          end

          it 'returns the person' do
            expect(person_hash[:id]).to eq(person.id)
            expect(person_hash.dig(:attributes, :first_names)).to eq(person.first_names)
          end

          it 'returns the ethnicity' do
            expect(ethnicity_hash.dig(:data, :attributes, :title)).to eq('White British')
          end

          it 'returns the gender' do
            expect(gender_hash.dig(:data, :attributes, :title)).to eq('Female')
          end

          it 'returns the events' do
            expect(events_hash.map { _1.dig(:data, :id) }).to match_array(events.pluck(:id))
          end

          it 'returns the moves' do
            expect(moves_hash.map { _1.dig(:data, :id) }).to match_array(moves.pluck(:id))
          end

          it 'returns the moves court hearings' do
            court_hearings_hash = moves_hash.flat_map { _1.dig(:data, :relationships, :court_hearings) }

            expect(court_hearings_hash.count).not_to eq(0)
            expect(court_hearings_hash.count).to eq(court_hearings.count)
            expect(court_hearings_hash.map { _1.dig(:data, :id) }).to match_array(court_hearings.pluck(:id))
          end

          it 'returns the moves events' do
            events_hash = moves_hash.flat_map { _1.dig(:data, :relationships, :events) }

            expect(events_hash.count).not_to eq(0)
            expect(events_hash.count).to eq(moves_events.count)
            expect(events_hash.map { _1.dig(:data, :id) }).to match_array(moves_events.pluck(:id))
          end

          it 'returns the journeys' do
            expect(journeys_hash.map { _1.dig(:data, :id) }).to match_array(journeys.pluck(:id))
          end

          it 'returns the moves locations' do
            move_hash = moves_hash.dig(0, :data)
            move = Move.find(move_hash[:id])
            move_relationships = move_hash[:relationships]
            from_location = move_relationships.dig(:from_location, :data)
            to_location = move_relationships.dig(:to_location, :data)

            expect(from_location[:id]).to eq(move.from_location_id)
            expect(from_location.dig(:attributes, :title)).to eq(move.from_location.title)
            expect(to_location[:id]).to eq(move.to_location_id)
            expect(to_location.dig(:attributes, :title)).to eq(move.to_location.title)
          end

          it 'returns the journeys events' do
            events_hash = journeys_hash.flat_map { _1.dig(:data, :relationships, :events) }

            expect(events_hash.count).not_to eq(0)
            expect(events_hash.count).to eq(journeys_events.count)
            expect(events_hash.map { _1.dig(:data, :id) }).to match_array(journeys_events.pluck(:id))
          end

          it 'returns the journeys locations' do
            journey_hash = journeys_hash.dig(0, :data)
            journey = Journey.find(journey_hash[:id])
            journey_relationships = journey_hash[:relationships]
            from_location = journey_relationships.dig(:from_location, :data)
            to_location = journey_relationships.dig(:to_location, :data)

            expect(from_location[:id]).to eq(journey.from_location_id)
            expect(from_location.dig(:attributes, :title)).to eq(journey.from_location.title)
            expect(to_location[:id]).to eq(journey.to_location_id)
            expect(to_location.dig(:attributes, :title)).to eq(journey.to_location.title)
          end

          it 'returns the profiles' do
            expect(profiles_hash.map { _1.dig(:data, :id) }).to match_array(profiles.pluck(:id))
          end

          it 'returns the profiles pers' do
            pers = profiles_hash.flat_map { _1.dig(:data, :relationships, :person_escort_record, :data) }.select(&:present?)

            expect(pers.count).to eq(1)
            expect(pers.dig(0, :id)).to eq(per_profile.person_escort_record.id)
          end

          it 'returns the profiles pers events' do
            pers = profiles_hash.flat_map { _1.dig(:data, :relationships, :person_escort_record, :data) }.select(&:present?)
            events = pers.flat_map { _1.dig(:relationships, :events) }

            expect(events.count).not_to eq(0)
            expect(events.map { _1.dig(:data, :id) }).to match_array(pers_events.pluck(:id))
          end

          it 'returns the profiles pers responses' do
            pers = profiles_hash.flat_map { _1.dig(:data, :relationships, :person_escort_record, :data) }.select(&:present?)
            responses = pers.flat_map { _1.dig(:relationships, :framework_responses) }

            expect(responses.count).not_to eq(0)
            expect(responses.map { _1.dig(:data, :id) }).to match_array(per_profile.person_escort_record.framework_responses.pluck(:id))
          end

          it 'returns the profiles pers responses questions' do
            pers = profiles_hash.flat_map { _1.dig(:data, :relationships, :person_escort_record, :data) }.select(&:present?)
            responses = pers.flat_map { _1.dig(:relationships, :framework_responses) }
            questions = responses.flat_map { _1.dig(:data, :relationships, :question) }

            expect(questions.count).not_to eq(0)
            expect(questions.map { _1.dig(:data, :id) }).to match_array(per_profile.person_escort_record.framework_responses.pluck(:framework_question_id))
          end

          it 'returns the profiles yras' do
            yras = profiles_hash.flat_map { _1.dig(:data, :relationships, :youth_risk_assessment, :data) }.select(&:present?)

            expect(yras.count).to eq(1)
            expect(yras.dig(0, :id)).to eq(yra_profile.youth_risk_assessment.id)
          end

          it 'returns the profiles yras responses' do
            yras = profiles_hash.flat_map { _1.dig(:data, :relationships, :youth_risk_assessment, :data) }.select(&:present?)
            responses = yras.flat_map { _1.dig(:relationships, :framework_responses) }

            expect(responses.count).not_to eq(0)
            expect(responses.map { _1.dig(:data, :id) }).to match_array(yra_profile.youth_risk_assessment.framework_responses.pluck(:id))
          end

          it 'returns the profiles yras responses questions' do
            yras = profiles_hash.flat_map { _1.dig(:data, :relationships, :youth_risk_assessment, :data) }.select(&:present?)
            responses = yras.flat_map { _1.dig(:relationships, :framework_responses) }
            questions = responses.flat_map { _1.dig(:data, :relationships, :question) }

            expect(questions.count).not_to eq(0)
            expect(questions.map { _1.dig(:data, :id) }).to match_array(yra_profile.youth_risk_assessment.framework_responses.pluck(:framework_question_id))
          end

          it 'returns the profiles documents' do
            documents = profiles_hash.flat_map { |p| p.dig(:data, :relationships, :documents).map { |d| d[:data] } }

            expect(documents.count).to eq(1)
            expect(documents.dig(0, :attributes, :filename)).to eq('file-sample_100kB.doc')
          end
        end

        context 'when multiple Persons are found matching the identifier' do
          let!(:person1) { create(:person, prison_number: 'test') }
          let!(:person2) { create(:person, prison_number: 'test') }

          before do
            get_sar
          end

          it 'returns a response object with status 200' do
            expect(response.status).to eq 200
          end
        end
      end
    end
  end
end
