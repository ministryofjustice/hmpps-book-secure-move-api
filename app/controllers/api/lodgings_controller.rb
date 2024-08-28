# frozen_string_literal: true

module Api
  class LodgingsController < ApiController
    include Idempotentable
    include Eventable

    before_action :validate_params, only: %i[create update]
    before_action :validate_idempotency_key, only: %i[create update cancel]
    around_action :idempotent_action, only: %i[create update cancel]
    after_action :create_modify_event, only: %i[create cancel]

    PERMITTED_NEW_PARAMS = [
      :type,
      { attributes: %i[start_date end_date],
        relationships: [location: {}, move: {}] },
    ].freeze

    PERMITTED_UPDATE_PARAMS = [
      :type,
      { attributes: %i[end_date],
        relationships: [location: {}] },
    ].freeze

    PERMITTED_CANCEL_PARAMS = [
      :type,
      { attributes: %i[cancellation_reason cancellation_reason_comment] },
    ].freeze

    def index
      paginate lodgings, serializer: LodgingsSerializer, include: included_relationships
    end

    def create
      authorize!(:create, lodging)

      lodging.save!
      render_lodging(lodging, :created)

      Notifier.prepare_notifications(topic: lodging, action_name: 'create')
    end

    def update
      authorize!(:update, lodging)

      details = {}

      if update_lodging_attributes[:end_date].present? && update_lodging_attributes[:end_date] != lodging.end_date
        details[:old_end_date] = lodging.end_date
        details[:end_date] = update_lodging_attributes[:end_date]
      end

      if update_lodging_attributes[:location_id].present? && update_lodging_attributes[:location_id] != lodging.location_id
        details[:old_location_id] = lodging.location_id
        details[:location_id] = update_lodging_attributes[:location_id]
      end

      if details.present?
        Lodging.transaction do
          update_future_lodgings(details)

          lodging.update!(update_lodging_attributes)

          create_automatic_event!(eventable: lodging, event_class: GenericEvent::LodgingUpdate, details:)

          Notifier.prepare_notifications(topic: lodging, action_name: 'update')
        end
      end

      render_lodging(lodging, :ok)
    end

    def cancel
      authorize!(:cancel, Lodging)

      if lodging.cancel
        lodging.save!

        return render status: :no_content
      end

      return render json: { error: 'Lodging already cancelled' }, status: :bad_request if lodging.cancelled?

      render json: { error: "#{lodging.status.titleize} lodgings may not be cancelled" }, status: :bad_request
    end

    def cancel_all
      authorize!(:cancel, Lodging)

      Lodging.transaction do
        move.lodgings.not_cancelled.each do |lodging|
          lodging.cancel
          lodging.save!

          create_automatic_event!(eventable: lodging, event_class: GenericEvent::LodgingCancel, details: {
            start_date: lodging.start_date,
            end_date: lodging.end_date,
            location_id: lodging.location_id,
            cancellation_reason: cancel_lodging_params.dig(:attributes, :cancellation_reason),
            cancellation_reason_comment: cancel_lodging_params.dig(:attributes, :cancellation_reason_comment),
          })

          Notifier.prepare_notifications(topic: lodging, action_name: 'cancel')
        end
      end

      render status: :no_content
    end

  private

    def update_future_lodgings(details)
      return if details[:end_date].blank? || move.lodgings.not_cancelled.count < 2

      start_date = Date.parse(lodging.start_date)
      old_length = Date.parse(lodging.end_date) - start_date
      new_length = Date.parse(update_lodging_attributes[:end_date]) - start_date
      length_difference = new_length - old_length

      move.lodgings.not_cancelled.each do |l|
        l_start_date = Date.parse(l.start_date)
        next if start_date >= l_start_date

        l_details = {
          old_start_date: l.start_date,
          start_date: l_start_date + length_difference.days,
          old_end_date: l.end_date,
          end_date: Date.parse(l.end_date) + length_difference.days,
        }

        l.update!(l_details.slice(:start_date, :end_date))

        create_automatic_event!(eventable: l, event_class: GenericEvent::LodgingUpdate, details: l_details)

        Notifier.prepare_notifications(topic: l, action_name: 'update')
      end
    end

    def render_lodging(lodging, status)
      render_json lodging, serializer: LodgingSerializer, include: included_relationships, status:
    end

    def supported_relationships
      # for performance reasons, we support fewer include relationships on the index action
      if action_name == 'index'
        LodgingsSerializer::SUPPORTED_RELATIONSHIPS
      else
        LodgingSerializer::SUPPORTED_RELATIONSHIPS
      end
    end

    def move
      @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
    end

    def lodgings
      @lodgings ||= move.lodgings.default_order.not_cancelled
    end

    def lodging
      @lodging ||= if action_name == 'create'
                     new_lodging
                   else
                     find_lodging
                   end
    end

    def new_lodging
      Lodging.new(new_lodging_attributes)
    end

    def find_lodging
      move.lodgings.find(params.require(:id)).tap do |lodging|
        raise CanCan::AccessDenied.new('Not authorized', :manage, Lodging) unless current_ability.can?(:manage, lodging)
      end
    end

    def validate_params
      Lodgings::ParamsValidator.new(data_params).validate!(action_name.to_sym)
    end

    def data_params
      @data_params ||= params.require(:data)
    end

    def new_lodging_params
      @new_lodging_params ||= data_params.permit(PERMITTED_NEW_PARAMS)
    end

    def new_lodging_attributes
      @new_lodging_attributes ||= new_lodging_params.to_h[:attributes].tap do |attribs|
        attribs.merge!(
          move:,
          location: find_location(new_lodging_params.require(:relationships).require(:location).require(:data).require(:id)),
        )
      end
    end

    def find_location(location_id)
      # Finds the referenced location or throws an ActiveModel::ValidationError (which will render as 422 Unprocessable Content)
      location = Location.find_or_initialize_by(id: location_id)
      unless location.persisted?
        location.errors.add(:location, "reference was not found id=#{location_id}")
        raise ActiveModel::ValidationError, location
      end
      location
    end

    def update_lodging_params
      @update_lodging_params ||= data_params.permit(PERMITTED_UPDATE_PARAMS)
    end

    def update_lodging_attributes
      attributes = update_lodging_params.to_h[:attributes] || {}
      location_id = update_lodging_params.dig(:relationships, :location, :data, :id)
      attributes[:location_id] = location_id if location_id.present?

      @update_lodging_attributes ||= attributes.tap do |attribs|
        attribs.delete(:timestamp) # throw the timestamp away for updates
        attribs.delete(:date) if attribs[:date].nil?
      end
    end

    def cancel_lodging_params
      @cancel_lodging_params ||= data_params.permit(PERMITTED_CANCEL_PARAMS)
    end

    def create_modify_event
      event_class = case action_name
                    when 'cancel'
                      GenericEvent::LodgingCancel
                    when 'create'
                      GenericEvent::LodgingCreate
                    else
                      return
                    end

      details = case action_name
                when 'cancel'
                  {
                    cancellation_reason: cancel_lodging_params.dig(:attributes, :cancellation_reason),
                    cancellation_reason_comment: cancel_lodging_params.dig(:attributes, :cancellation_reason_comment),
                    end_date: lodging.end_date,
                    location_id: lodging.location_id,
                    start_date: lodging.start_date,
                  }
                when 'create'
                  {
                    end_date: lodging.end_date,
                    location_id: lodging.location_id,
                    start_date: lodging.start_date,
                  }
                else
                  {}
                end

      create_automatic_event!(eventable: lodging, event_class:, details:)
    end
  end
end
