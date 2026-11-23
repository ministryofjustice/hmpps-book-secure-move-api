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

    def stub_subject_access_request
      sar_double = instance_double(SubjectAccessRequest, empty?: false, fetch: {})
      allow(SubjectAccessRequest).to receive(:new).and_return(sar_double)
    end

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

      context 'when date parameters are provided as camelCase' do
        let!(:person) { create(:person_without_profiles, prison_number: 'test') }
        let(:from_date) { '2024-01-01' }
        let(:to_date) { '2024-12-31' }
        let(:params) { { prn: 'test', fromDate: from_date, toDate: to_date } }

        before do
          stub_subject_access_request
          get_sar
        end

        it 'accepts camelCase parameters and passes parsed dates' do
          expect(response.status).to eq 200
          expect(SubjectAccessRequest).to have_received(:new).with(
            'test',
            Date.new(2024, 1, 1),
            Date.new(2024, 12, 31),
          )
        end
      end

      context 'when date parameters are provided as snake_case' do
        let!(:person) { create(:person_without_profiles, prison_number: 'test') }
        let(:from_date) { '2024-01-01' }
        let(:to_date) { '2024-12-31' }
        let(:params) { { prn: 'test', from_date: from_date, to_date: to_date } }

        before do
          stub_subject_access_request
          get_sar
        end

        it 'accepts snake_case parameters and passes parsed dates' do
          expect(response.status).to eq 200
          expect(SubjectAccessRequest).to have_received(:new).with(
            'test',
            Date.new(2024, 1, 1),
            Date.new(2024, 12, 31),
          )
        end
      end

      context 'when no date parameters are provided' do
        let!(:person) { create(:person_without_profiles, prison_number: 'test') }
        let(:params) { { prn: 'test' } }

        before do
          stub_subject_access_request
          get_sar
        end

        it 'uses default date range' do
          expect(SubjectAccessRequest).to have_received(:new).with(
            'test',
            Date.new(1000),
            Date.new(3000),
          )
        end
      end

      context 'when both camelCase and snake_case date parameters are provided' do
        let!(:person) { create(:person_without_profiles, prison_number: 'test') }
        let(:params) do
          {
            prn: 'test',
            from_date: '2024-01-01',
            fromDate: '2025-01-01',
            to_date: '2024-12-31',
            toDate: '2025-12-31',
          }
        end

        before do
          stub_subject_access_request
          get_sar
        end

        it 'prefers camelCase parameters' do
          expect(SubjectAccessRequest).to have_received(:new).with(
            'test',
            Date.new(2025, 1, 1),
            Date.new(2025, 12, 31),
          )
        end
      end

      context 'when invalid date parameters are provided via camelCase' do
        let(:params) { { prn: 'test', fromDate: 'ABC', toDate: 'XYZ' } }

        before do
          get_sar
        end

        it 'returns validation error with status 400' do
          expect(response.status).to eq 400
          response_body = JSON.parse(response.body)
          expect(response_body['error']).to be_present
        end
      end

      context 'when invalid snake_case date is provided with valid camelCase' do
        let!(:person) { create(:person_without_profiles, prison_number: 'test') }
        let(:params) do
          {
            prn: 'test',
            from_date: 'not-a-date',
            fromDate: '2025-01-01',
            to_date: 'invalid',
            toDate: '2025-12-31',
          }
        end

        before do
          sar_instance = instance_double(SubjectAccessRequest, empty?: false, fetch: {})
          allow(SubjectAccessRequest).to receive(:new).and_return(sar_instance)
          get_sar
        end

        it 'uses camelCase dates when valid, ignoring invalid snake_case' do
          expect(response.status).to eq 200
          expect(SubjectAccessRequest).to have_received(:new).with(
            'test',
            Date.new(2025, 1, 1),
            Date.new(2025, 12, 31),
          )
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
          let!(:moves) { [create(:move, profile: per_profile, recall_date: Date.new(2023, 1, 2)), create(:move, profile: per_profile, recall_date: nil), create(:move, profile: yra_profile)] }
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

          it 'returns the moves recall dates' do
            recall_dates = moves_hash.to_h { [_1.dig(:data, :id), _1.dig(:data, :attributes, :recall_date)] }

            expect(recall_dates[moves.first.id]).to eq('2023-01-02')
            expect(recall_dates[moves.second.id]).to be_nil
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
          let!(:person1) { create(:person_without_profiles, prison_number: 'test', created_at: 2.days.ago) }
          let!(:person2) { create(:person_without_profiles, prison_number: 'test', created_at: 1.day.ago) }
          let!(:other_person) { create(:person_without_profiles, prison_number: 'other') }
          let(:profile1) { create(:profile, person: person1) }
          let(:profile2) { create(:profile, person: person2) }
          let!(:person1_later_move) { create(:move, profile: profile1, date: Date.new(2024, 6, 1)) }
          let!(:person2_move) { create(:move, profile: profile2, date: Date.new(2024, 3, 1)) }
          let!(:person1_earlier_move) { create(:move, profile: profile1, date: Date.new(2023, 1, 1)) }
          let!(:other_person_move) { create(:move, profile: create(:profile, person: other_person), date: Date.new(2024, 1, 1)) }
          let(:content) { JSON.parse(response.body, symbolize_names: true)[:content] }

          before do
            get_sar
          end

          it 'returns a response object with status 200' do
            expect(response.status).to eq 200
          end

          it 'returns one entry per record, oldest first' do
            expect(content.map { _1.dig(:data, :id) }).to eq([person1.id, person2.id])
          end

          it 'returns each record\'s own moves ordered by move date' do
            move_ids = content.map { |c| c.dig(:data, :relationships, :moves).map { _1.dig(:data, :id) } }

            expect(move_ids).to eq([[person1_earlier_move.id, person1_later_move.id], [person2_move.id]])
          end

          it 'does not return moves for other prison numbers' do
            move_ids = content.flat_map { |c| c.dig(:data, :relationships, :moves).map { _1.dig(:data, :id) } }

            expect(move_ids).not_to include(other_person_move.id)
          end
        end

        context 'when a date range is provided' do
          let(:params) { { prn: 'test', fromDate: '2024-01-01', toDate: '2024-12-31' } }
          let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: Date.new(2023, 1, 1)) }
          let(:old_profile) { create(:profile, person:) }
          let(:new_profile) { create(:profile, person:) }
          let(:move_ids) do
            JSON.parse(response.body, symbolize_names: true)
                .dig(:content, 0, :data, :relationships, :moves)
                .map { _1.dig(:data, :id) }
          end

          let!(:late_2024_move) { create(:move, profile: old_profile, date: Date.new(2024, 11, 1), date_from: nil, date_to: nil) }
          let!(:before_range_move) { create(:move, profile: old_profile, date: Date.new(2023, 12, 31), date_from: nil, date_to: nil) }
          let!(:mid_2024_move) { create(:move, profile: new_profile, date: Date.new(2024, 6, 1), date_from: nil, date_to: nil) }
          let!(:after_range_move) { create(:move, profile: new_profile, date: Date.new(2025, 1, 1), date_from: nil, date_to: nil) }
          let!(:last_day_move) { create(:move, profile: old_profile, date: Date.new(2024, 12, 31), date_from: nil, date_to: nil) }
          let!(:proposed_move) { create(:move, :proposed, profile: new_profile, date: nil, date_from: Date.new(2024, 3, 1), date_to: nil) }
          let!(:proposed_out_of_range_move) { create(:move, :proposed, profile: new_profile, date: nil, date_from: Date.new(2025, 3, 1), date_to: nil) }
          let!(:undated_cancelled_move) { create(:move, :cancelled, profile: old_profile, date: nil, date_from: nil, date_to: nil, created_at: Time.zone.local(2024, 5, 1, 10)) }
          let!(:undated_cancelled_out_of_range_move) { create(:move, :cancelled, profile: old_profile, date: nil, date_from: nil, date_to: nil, created_at: Time.zone.local(2025, 5, 1, 10)) }

          before do
            get_sar
          end

          it 'only returns moves whose date, date_from or created_at (in that order of preference) is within the range' do
            expect(move_ids).not_to include(before_range_move.id, after_range_move.id, proposed_out_of_range_move.id, undated_cancelled_out_of_range_move.id)
          end

          it 'returns the moves ordered by move date' do
            expect(move_ids).to eq([proposed_move.id, undated_cancelled_move.id, mid_2024_move.id, late_2024_move.id, last_day_move.id])
          end
        end

        context 'when records are created around the end of the toDate' do
          let(:params) { { prn: 'test', fromDate: '2024-01-01', toDate: '2024-12-31' } }
          let(:end_of_to_date) { Time.zone.local(2024, 12, 31, 23, 59, 59) }
          let(:start_of_next_day) { Time.zone.local(2025, 1, 1, 0, 0, 0) }
          let!(:person_on_to_date) { create(:person_without_profiles, prison_number: 'test', created_at: end_of_to_date) }
          let!(:person_after_to_date) { create(:person_without_profiles, prison_number: 'test', created_at: start_of_next_day) }
          let!(:profile_on_to_date) { create(:profile, person: person_on_to_date, created_at: end_of_to_date) }
          let!(:profile_after_to_date) { create(:profile, person: person_on_to_date, created_at: start_of_next_day) }
          let(:content) { JSON.parse(response.body, symbolize_names: true)[:content] }

          before do
            get_sar
          end

          it 'includes people created at any time on the toDate, but not after it' do
            expect(content.map { _1.dig(:data, :id) }).to eq([person_on_to_date.id])
          end

          it 'includes profiles created at any time on the toDate, but not after it' do
            profile_ids = content.dig(0, :data, :relationships, :profiles).map { _1.dig(:data, :id) }

            expect(profile_ids).to eq([profile_on_to_date.id])
          end
        end

        context 'when framework responses have been answered with empty values' do
          let!(:person) { create(:person_without_profiles, prison_number: 'test') }
          let(:per) { create(:person_escort_record, profile: create(:profile, person:)) }
          let!(:empty_object_response) { create(:object_response, assessmentable: per, responded: true, value: {}) }
          let!(:empty_array_response) { create(:array_response, assessmentable: per, responded: true, value: []) }
          let!(:empty_string_response) { create(:string_response, assessmentable: per, responded: true, value: '') }
          let!(:object_response) { create(:object_response, :details, assessmentable: per, responded: true) }
          let!(:array_response) { create(:array_response, assessmentable: per, responded: true) }
          let!(:string_response) { create(:string_response, assessmentable: per, responded: true) }
          let(:values) do
            JSON.parse(response.body, symbolize_names: false)
                .dig('content', 0, 'data', 'relationships', 'profiles', 0, 'data', 'relationships', 'person_escort_record', 'data', 'relationships', 'framework_responses')
                .to_h { [_1.dig('data', 'id'), _1.dig('data', 'attributes', 'value')] }
          end

          before do
            get_sar
          end

          it 'returns nil for empty values' do
            expect(values.values_at(empty_object_response.id, empty_array_response.id, empty_string_response.id)).to eq([nil, nil, nil])
          end

          it 'returns populated values unchanged' do
            expect(values[object_response.id]).to eq('option' => 'Yes', 'details' => 'some comment')
            expect(values[array_response.id]).to eq(['Level 1'])
            expect(values[string_response.id]).to eq('Yes')
          end
        end

        context 'when the person exists but has no data in the requested range' do
          let(:content) { JSON.parse(response.body, symbolize_names: true)[:content] }

          context 'when the person was created on the toDate but their profile and move are from the day after' do
            let(:params) { { prn: 'test', toDate: '2023-04-10' } }
            let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2023, 4, 10, 15)) }
            let!(:profile) { create(:profile, person:, created_at: Time.zone.local(2023, 4, 11, 9)) }
            let!(:move) { create(:move, profile:, date: Date.new(2023, 4, 11)) }

            before { get_sar }

            it 'returns a response object with status 204' do
              expect(response.status).to eq 204
            end
          end

          context 'when the person and their moves are all before the fromDate' do
            let(:params) { { prn: 'test', fromDate: '2024-01-01', toDate: '2024-12-31' } }
            let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2023, 1, 1)) }
            let!(:profile) { create(:profile, person:, created_at: Time.zone.local(2023, 1, 1)) }
            let!(:move) { create(:move, profile:, date: Date.new(2023, 6, 1)) }

            before { get_sar }

            it 'returns a response object with status 204' do
              expect(response.status).to eq 204
            end
          end

          context 'when the person has a profile created in the range but no moves in it' do
            let(:params) { { prn: 'test', fromDate: '2024-01-01', toDate: '2024-12-31' } }
            let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2023, 1, 1)) }
            let!(:profile) { create(:profile, person:, created_at: Time.zone.local(2024, 6, 1)) }

            before { get_sar }

            it 'returns a response object with status 200 including the profile' do
              expect(response.status).to eq 200
              expect(content.dig(0, :data, :relationships, :profiles).map { _1.dig(:data, :id) }).to eq([profile.id])
            end
          end

          context 'when a duplicate person record has no data in the range' do
            let(:params) { { prn: 'test', fromDate: '2024-01-01', toDate: '2024-12-31' } }
            let!(:person_with_data) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2023, 1, 1)) }
            let!(:person_without_data) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2023, 1, 1)) }
            let!(:move) { create(:move, profile: create(:profile, person: person_with_data, created_at: Time.zone.local(2023, 1, 1)), date: Date.new(2024, 6, 1)) }
            let!(:old_move) { create(:move, profile: create(:profile, person: person_without_data, created_at: Time.zone.local(2023, 1, 1)), date: Date.new(2023, 6, 1)) }

            before { get_sar }

            it 'only returns the person record with data in the range' do
              expect(response.status).to eq 200
              expect(content.map { _1.dig(:data, :id) }).to eq([person_with_data.id])
            end
          end
        end

        context 'when records are created just after midnight during British Summer Time' do
          # 00:30 BST on 1 July is 23:30 UTC on 30 June, but is 1 July in the UK
          let(:just_after_midnight_bst) { Time.zone.local(2024, 7, 1, 0, 30) }
          let(:content) { JSON.parse(response.body, symbolize_names: true)[:content] }

          context 'with an undated cancelled move and a range starting that day' do
            let(:params) { { prn: 'test', fromDate: '2024-07-01', toDate: '2024-07-31' } }
            let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2024, 1, 1)) }
            let!(:profile) { create(:profile, person:, created_at: Time.zone.local(2024, 1, 1)) }
            let!(:move) { create(:move, :cancelled, profile:, date: nil, date_from: nil, date_to: nil, created_at: just_after_midnight_bst) }

            before { get_sar }

            it 'includes the move using its UK creation date' do
              expect(response.status).to eq 200
              expect(content.dig(0, :data, :relationships, :moves).map { _1.dig(:data, :id) }).to eq([move.id])
            end
          end

          context 'with a range ending the day before' do
            let(:params) { { prn: 'test', toDate: '2024-06-30' } }
            let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: just_after_midnight_bst) }
            let!(:profile) { create(:profile, person:, created_at: just_after_midnight_bst) }

            before { get_sar }

            it 'excludes the person and profile and returns 204' do
              expect(response.status).to eq 204
            end
          end

          context 'with a range starting that day' do
            let(:params) { { prn: 'test', fromDate: '2024-07-01', toDate: '2024-07-31' } }
            let!(:person) { create(:person_without_profiles, prison_number: 'test', created_at: Time.zone.local(2024, 1, 1)) }
            let!(:profile) { create(:profile, person:, created_at: just_after_midnight_bst) }

            before { get_sar }

            it 'counts the profile as data held in the range' do
              expect(response.status).to eq 200
              expect(content.dig(0, :data, :relationships, :profiles).map { _1.dig(:data, :id) }).to eq([profile.id])
            end
          end
        end
      end
    end
  end
end
