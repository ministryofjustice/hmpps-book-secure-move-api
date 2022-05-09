# frozen_string_literal: true

module Api
  class JourneysController < ApiController
    include Idempotentable
    include Eventable

    before_action :validate_params, only: %i[create update]
    before_action :validate_duplicate_journey, only: %i[create]
    before_action :validate_idempotency_key, only: %i[create update]
    around_action :idempotent_action, only: %i[create update]
    after_action :create_journey_event, only: %i[create update]

    PERMITTED_NEW_JOURNEY_PARAMS = [
      :type,
      { attributes: [:timestamp, :billable, { vehicle: {} }, :date],
        relationships: [from_location: {}, to_location: {}, supplier: {}] },
    ].freeze

    PERMITTED_UPDATE_JOURNEY_PARAMS = [
      :type,
      { attributes: [:timestamp, :billable, { vehicle: {} }, :date] },
    ].freeze

    def index
      paginate journeys, serializer: JourneysSerializer, include: included_relationships
    end

    def show
      render_journey(journey, :ok)
    end

    def create
      authorize!(:create, journey)
      journey.save!
      render_journey(journey, :created)
    end

    def update
      journey.update!(update_journey_attributes)
      render_journey(journey, :ok)
    end

  private

    def render_journey(journey, status)
      render_json journey, serializer: JourneySerializer, include: included_relationships, status: status
    end

    def supported_relationships
      # for performance reasons, we support fewer include relationships on the index action
      if action_name == 'index'
        JourneysSerializer::SUPPORTED_RELATIONSHIPS
      else
        JourneySerializer::SUPPORTED_RELATIONSHIPS
      end
    end

    def move
      @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
    end

    def journeys
      @journeys ||= move.journeys.accessible_by(current_ability).default_order
    end

    def journey
      @journey ||= if action_name == 'create'
                     new_journey
                   else
                     find_journey
                   end
    end

    def new_journey
      Journey.new(new_journey_attributes)
    end

    def find_journey
      move.journeys.find(params.require(:id)).tap do |journey|
        raise CanCan::AccessDenied.new('Not authorized', :manage, Journey) unless current_ability.can?(:manage, journey)
      end
    end

    def validate_params
      Journeys::ParamsValidator.new(data_params).validate!(action_name.to_sym)
    end

    def validate_duplicate_journey
      move_journeys = move.journeys
      params_from_location = data_params['relationships']['from_location']['data']['id']
      params_to_location = data_params['relationships']['to_location']['data']['id']

      move_journeys.each do |journey|
        next if journey.state == 'cancelled' || journey.state == 'rejected' || journey.to_location_id != params_to_location || journey.from_location_id != params_from_location

        render(
          json: { errors: [{
            title: 'Bad request',
            detail: 'You are trying to submit a duplicate journey for this move, please try again',
          }] },
          status: :bad_request,
        )
      end
    end

    def data_params
      @data_params ||= params.require(:data)
    end

    def new_journey_params
      @new_journey_params ||= data_params.permit(PERMITTED_NEW_JOURNEY_PARAMS)
    end

    def new_journey_attributes
      @new_journey_attributes ||= new_journey_params.to_h[:attributes].tap do |attribs|
        timestamp = attribs.delete(:timestamp) # throw the timestamp away as we are using client_timestamp instead
        attribs.merge!(
          move: move,
          client_timestamp: Time.zone.parse(timestamp),
          date: attribs.delete(:date) || move.date,
          from_location: find_location(new_journey_params.require(:relationships).require(:from_location).require(:data).require(:id)),
          to_location: find_location(new_journey_params.require(:relationships).require(:to_location).require(:data).require(:id)),
          supplier: supplier,
        )
      end
    end

    def find_location(location_id)
      # Finds the referenced location or throws an ActiveModel::ValidationError (which will render as 422 Unprocessable Entity)
      location = Location.find_or_initialize_by(id: location_id)
      unless location.persisted?
        location.errors.add(:location, "reference was not found id=#{location_id}")
        raise ActiveModel::ValidationError, location
      end
      location
    end

    def find_supplier(supplier_id)
      # NB: finds the supplier specified by id or uses the current_user's supplier account. Will raise an exception if not found or not accessible
      supplier = Supplier.find_by(id: supplier_id) || current_user.owner
      if supplier.nil? || (current_user.owner.present? && supplier != current_user.owner)
        supplier.errors.add(:supplier, "reference is not valid for this account or not found id=#{supplier_id}")
        raise ActiveModel::ValidationError, supplier
      end
      supplier
    end

    def supplier
      # NB: the supplier_id is typically blank as we generally use the logged-in account
      @supplier ||= find_supplier(data_params.dig(:relationships, :supplier, :data, :id))
    end

    def update_journey_params
      @update_journey_params ||= data_params.permit(PERMITTED_UPDATE_JOURNEY_PARAMS)
    end

    def update_journey_attributes
      @update_journey_attributes ||= update_journey_params.to_h[:attributes].tap do |attribs|
        attribs.delete(:timestamp) # throw the timestamp away for updates
        attribs.delete(:date) if attribs[:date].nil?
      end
    end

    def create_journey_event
      event_class = case action_name
                    when 'update'
                      GenericEvent::JourneyUpdate
                    when 'create'
                      GenericEvent::JourneyCreate
                    end

      create_automatic_event!(eventable: journey, event_class: event_class, supplier_id: supplier.id)
    end
  end
end
