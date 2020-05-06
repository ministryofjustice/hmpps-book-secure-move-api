module Api
  module V2
    class CourtCases < Grape::API
      prefix 'api/v2'
      version 'v2', using: :header, vendor: 'vendor'

      content_type :jsonapi, 'application/vnd.api+json'

      formatter :json, Grape::Formatter::FastJsonapi
      formatter :jsonapi, Grape::Formatter::FastJsonapi

      format :jsonapi

      helpers do
        def person
          @person ||= Person.find(params[:person_id])
        end

        def court_case_filter_params
          return unless params[:filter]
        end

        def serializer
          FastJsonapi::CourtCaseSerializer
        end
      end

      get '/people/:person_id/court_cases' do
        response = People::RetrieveCourtCases.call(person, court_case_filter_params)

        court_cases = serializer.new(
          response.court_cases,
          include: [:location],
        ).serializable_hash

        render court_cases
      end
    end
  end
end
