# frozen_string_literal: true

module Api
  class PopulationsController < ApiController
    before_action :validate_date_range_params, only: %i[index]

    rescue_from Date::Error, with: :render_invalid_date_error

    def new
      new_population = Population.new_with_defaults(location: location, date: date)

      render_population(new_population, :ok)
    end

    def index
      paginate locations, serializer: LocationFreeSpacesSerializer, include: included_relationships do |paginated_locations, options|
        options[:params] = { spaces: Population.free_spaces_date_range(paginated_locations, (date_from..date_to)) }
      end
    end

    def show
      render_population(population, :ok)
    end

    def create
      new_population = Population.new(create_population_attributes).save_uniquely!

      render_population(new_population, :created)
    end

    def update
      population.assign_attributes(update_population_attributes)
      population.save_uniquely!

      render_population(population, :ok)
    end

  private

    PERMITTED_FILTER_PARAMS = %i[location_type nomis_agency_id supplier_id location_id region_id].freeze
    PERMITTED_SORT_PARAMS = %i[by direction].freeze
    PERMITTED_DATE_RANGE_PARAMS = %i[date_from date_to].freeze
    PERMITTED_POPULATION_PARAMS = %i[date operational_capacity usable_capacity unlock bedwatch overnights_in overnights_out out_of_area_courts discharges updated_by].freeze

    def filter_params
      params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
    end

    def sort_params
      params.fetch(:sort, {}).permit(PERMITTED_SORT_PARAMS).to_h
    end

    def date_range_params
      params.permit(PERMITTED_DATE_RANGE_PARAMS).to_h
    end

    def population_params
      params.require(:data).require(:attributes).permit(PERMITTED_POPULATION_PARAMS)
    end

    def parse_date(string_representation)
      Date.strptime(string_representation.to_s, '%Y-%m-%d')
    end

    def date
      parse_date(params[:date])
    end

    def date_from
      parse_date(date_range_params[:date_from])
    end

    def date_to
      parse_date(date_range_params[:date_to])
    end

    def validate_date_range_params
      Populations::ParamsValidator.new(date_range_params, sort_params).validate!
    end

    def location
      Location.find(params[:location_id])
    end

    def locations
      @locations ||= Locations::Finder.new(
        filter_params: filter_params,
        sort_params: sort_params,
        active_record_relationships: active_record_relationships,
      ).call
    end

    def location_id
      @location_id = params.require(:data).dig(:relationships, :location, :data, :id)
    end

    def create_population_attributes
      population_params.merge(location: Location.find(location_id)).to_h
    end

    def update_population_attributes
      population_params.tap { |hash|
        hash.merge!(location: Location.find(location_id)) if location_id.present?
      }.to_h
    end

    def population
      @population ||= Population.find(params[:id])
    end

    def render_population(population, status)
      render_json population, serializer: PopulationSerializer, include: included_relationships, status: status
    end

    def supported_relationships
      if action_name == 'index'
        LocationFreeSpacesSerializer::SUPPORTED_RELATIONSHIPS
      else
        PopulationSerializer::SUPPORTED_RELATIONSHIPS
      end
    end

    def render_invalid_date_error(_exception)
      render(
        json: { errors: [{
          title: 'Invalid date',
          detail: 'Date is not a valid date',
        }] },
        status: :unprocessable_entity,
      )
    end
  end
end
