require 'swagger_helper'

RSpec.describe Api::PeopleController, :with_client_authentication, :rswag, type: :request do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:booking_id) { '1200738' }
  let(:person) { create(:person, :nomis_synced, latest_nomis_booking_id: booking_id) }
  let(:person_id) { person.id }
  let(:'filter[date_to]') { Time.zone.now.to_date.iso8601 }
  let(:'filter[date_from]') { Time.zone.now.to_date.iso8601 }

  path '/people/{person_id}/timetable' do
    get 'Returns timetable entries for a date range which defaults to today' do
      tags 'People'
      produces 'application/vnd.api+json'

      parameter name: :Authorization,
                in: :header,
                schema: {
                  type: 'string',
                  default: 'Bearer <your-client-token>',
                },
                required: true,
                description: <<~DESCRIPTION
                  This is "Bearer ", followed by your OAuth 2 Client token.
                  If you're testing interactively in the web UI, you can ignore this field
                DESCRIPTION

      parameter name: 'Content-Type',
                in: 'header',
                description: 'Accepted request content type',
                schema: {
                  type: 'string',
                  default: 'application/vnd.api+json',
                },
                required: true

      parameter name: :person_id,
                in: :path,
                description: 'The ID of the person',
                schema: {
                  type: :string,
                },
                format: 'uuid',
                example: '00525ecb-7316-492a-aae2-f69334b2a155',
                required: true

      parameter name: :'filter[date_from]',
                in: :query,
                description: 'Filter timetable entries that start on and not before this date. Defaults to today',
                schema: { type: :string, example: '2020-04-28' },
                type: :string,
                format: :date,
                required: true

      parameter name: :'filter[date_to]',
                in: :query,
                description: 'Filter timetable entries that start up to and including this date. Defaults to today',
                schema: { type: :string, example: '2020-04-28' },
                type: :string,
                format: :date,
                required: true

      response '200', 'success' do
        before do
          allow(People::RetrieveTimetable).to receive(:call).and_return(timetable_result)
        end

        let(:timetable_result) do
          location = create(:location)

          activity = Activity.new.build_from_nomis(
            'eventId' => 401_732_488,
            'startTime' => '2020-04-22T08:30:00',
            'eventTypeDesc' => 'Prison Activities',
            'locationCode' => location.nomis_agency_id,
          )
          court_hearing = NomisCourtHearing.new.build_from_nomis(
            'id' => 330_253_339,
            'dateTime' => '2020-04-22T08:30:00',
            'location' => { 'agencyId' => location.nomis_agency_id },
          )

          OpenStruct.new(success?: true, content: [activity, court_hearing], error: nil)
        end
        let(:resource_to_json) do
          rendered = TimetableSerializer.new(timetable, include: :location).serializable_hash.to_json

          JSON.parse(rendered)
        end

        schema '$ref' => 'get_timetable_responses.yaml#/200'

        run_test!
      end

      response '401', 'unauthorised' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('bogus-credentials')}" }

        it_behaves_like 'a swagger 401 error'
      end

      response '404', 'not found' do
        let(:person_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find Person with 'id'=#{person_id}" }

        it_behaves_like 'a swagger 404 error'
      end

      response '415', 'invalid content type' do
        let(:"Content-Type") { 'application/xml' }

        it_behaves_like 'a swagger 415 error'
      end
    end
  end
end
