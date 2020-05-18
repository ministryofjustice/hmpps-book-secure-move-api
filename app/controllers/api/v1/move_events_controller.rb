# frozen_string_literal: true

module Api
  module V1
    class MoveEventsController < ApiController
      before_action :validate_params, :validate_idempotency_key

      PERMITTED_EVENT_PARAMS = [
          :type,
          attributes: %i[timestamp event_name notes],
          relationships: { to_location: {} },
      ].freeze

      def create
        # NB: this is a *temporary implementation* to immediately address the needs of P4-1355 and allow the frontend to
        # update the destination of a move. They will do this by POSTing a redirect event to this endpoint. For now, we
        # will simply update the move's to_location. In the future (P4-1180) we will have a funky immutable event log.

        case event_name
        when 'redirect'
          # NB: rather than update immediately, we need to detect whether the location has actually changed (or not) to
          # prevent triggering duplicate webhook/email notifications
          move.to_location = to_location
          if move.to_location_id_changed?
            move.save!
            Notifier.prepare_notifications(topic: move, action_name: 'update')
          end
          render json: fake_event_object, status: :created
        else
          render status: :bad_request, json: {
            errors: [{ title: 'invalid event_name', detail: "#{event_name} is not supported" }],
          }
        end
      end

    private

      def validate_params
        MoveEvents::ParamsValidator.new(event_params).tap do |validator|
          if validator.invalid?
            render status: :bad_request, json: {
              errors: validator.errors.map { |field, message| { title: field, detail: message } },
            }
          end
        end
      end

      def event_params
        @event_params ||= params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
      end

      def event_name
        @event_name ||= event_params.dig(:attributes, :event_name)
      end

      def timestamp
        @timestamp ||= Time.zone.parse(event_params.dig(:attributes, :timestamp))
      end

      def notes
        @notes ||= event_params.dig(:attributes, :notes)
      end

      def to_location
        @to_location ||= Location.find(event_params.dig(:relationships, :to_location, :data, :id))
      end

      def move
        @move ||= Move.accessible_by(current_ability).find(params.require(:move_id))
      end

      def event

      end

      def fake_event_object
        # NB: this is a temporarily implementation to simulate the creation of a new event
        {
          data: {
            id: SecureRandom.uuid,
            type: 'events',
            attributes: {
              event_name: event_name,
              timestamp: timestamp,
              notes: notes,
            },
            relationships: {
              to_location: {
                data: {
                  type: 'locations',
                  id: to_location.id,
                },
              },
            },
          },
        }
      end
    end
  end
end
