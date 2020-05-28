# frozen_string_literal: true

module Api
  module V1
    class AllocationEventsController < ApiController
      before_action :validate_params, only: :events
      after_action :send_move_notifications

      def cancel
        allocation.cancel(cancellation_details)

        render status: :no_content
      end

      def events
        # TODO: this method should be deleted, but kept here until the front end is updated
        case event_name
        when 'cancel'
          allocation.cancel

          render json: fake_event_object, status: :created
        else
          render status: :bad_request,
                 json: {
                   errors: [{ title: 'invalid event_name', detail: "#{event_name} is not supported" }],
                 }
        end
      end

    private

      # TODO: remove constant when allocation `events` endpoint is no longer in use
      PERMITTED_EVENT_PARAMS = [
        :type,
        attributes: %i[timestamp event_name],
      ].freeze

      PERMITTED_CANCEL_PARAMS = [
        attributes: %i[cancellation_reason cancellation_reason_comment],
      ].freeze

      def validate_params
        # TODO: remove ParamsValidator completely when allocation `events` endpoint is no longer in use
        AllocationEvents::ParamsValidator.new(event_params).validate!(:cancel)
      end

      def cancel_params
        params.require(:data).permit(PERMITTED_CANCEL_PARAMS).to_h
      end

      def cancellation_details
        {
          reason: cancel_params.dig(:attributes, :cancellation_reason),
        }.tap do |details|
          comment = cancel_params.dig(:attributes, :cancellation_reason_comment)
          details[:comment] = comment if comment
        end
      end

      def event_params
        # TODO: remove method completely when allocation `events` endpoint is no longer in use
        params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
      end

      def allocation
        @allocation ||= Allocation.find(params.require(:id))
      end

      def send_move_notifications
        allocation.moves.each do |move|
          Notifier.prepare_notifications(topic: move, action_name: 'update_status')
        end
      end

      def event_name
        # TODO: remove method completely when allocation `events` endpoint is no longer in use
        @event_name ||= event_params.dig(:attributes, :event_name)
      end

      def timestamp
        # TODO: remove method completely when allocation `events` endpoint is no longer in use
        @timestamp ||= Time.zone.parse(event_params.dig(:attributes, :timestamp))
      end

      def fake_event_object
        # TODO: remove method completely when allocation `events` endpoint is no longer in use
        # NB: this is a temporarily implementation to simulate the creation of a new event
        {
          data: {
            id: SecureRandom.uuid,
            type: 'events',
            attributes: {
              event_name: event_name,
              timestamp: timestamp,
            },
            relationships: {
              allocation: {
                data: {
                  type: 'allocations',
                  id: allocation.id,
                },
              },
            },
          },
        }
      end
    end
  end
end
