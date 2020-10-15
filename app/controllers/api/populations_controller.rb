# frozen_string_literal: true

module Api
  class PopulationsController < ApiController
    before_action :validate_date_range_params, only: %i[index]

    def index
      serializer_params = { populations: Population.free_spaces_date_range(locations, (date_from..date_to)) }

      paginate locations, serializer: LocationFreeSpacesSerializer, params: serializer_params
    end

    def show
      population = find_population

      render_population(population, :ok)
    end

  private

    PERMITTED_FILTER_PARAMS = %i[location_type nomis_agency_id supplier_id location_id region_id].freeze
    PERMITTED_SORT_PARAMS = %i[by direction].freeze
    PERMITTED_DATE_RANGE_PARAMS = %i[date_from date_to].freeze

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end

    def sort_params
      params.fetch(:sort, {}).permit(PERMITTED_SORT_PARAMS).to_h
    end

    def date_range_params
      params.permit(PERMITTED_DATE_RANGE_PARAMS).to_h
    end

    def date_from
      Date.strptime(date_range_params[:date_from], '%Y-%m-%d')
    end

    def date_to
      Date.strptime(date_range_params[:date_to], '%Y-%m-%d')
    end

    def validate_date_range_params
      Populations::ParamsValidator.new(date_range_params, sort_params).validate!
    end

    def locations
      @locations ||= Locations::Finder.new(filter_params, sort_params).call
    end

    def find_population
      Population.find(params[:id])
    end

    def render_population(population, status)
      render_json population, serializer: PopulationSerializer, include: included_relationships, status: status
    end

    def supported_relationships
      PopulationSerializer::SUPPORTED_RELATIONSHIPS
    end
  end
end
