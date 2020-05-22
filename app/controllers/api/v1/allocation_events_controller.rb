# frozen_string_literal: true

module Api
  module V1
    class AllocationEventsController < ApiController
      before_action :validate_params, only: :create
      after_action :send_move_notifications, only: :create

      def create
        case event_name
        when 'cancel'
          allocation.cancel

          allocation.save!
          render json: fake_event_object, status: :created
        else
          render status: :bad_request,
                 json: {
                   errors: [{ title: 'invalid event_name', detail: "#{event_name} is not supported" }],
                 }
        end
      end

    private

      PERMITTED_EVENT_PARAMS = [
        :type,
        attributes: %i[timestamp event_name],
      ].freeze

      def validate_params
        AllocationEvents::ParamsValidator.new(event_params).validate!(action_name.to_sym)
      end

      def event_params
        params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
      end

      def allocation
        @allocation ||= Allocation.find(params.require(:allocation_id))
      end

      def send_move_notifications
        allocation.moves.each do |move|
          Notifier.prepare_notifications(topic: move, action_name: 'update_status')
        end
      end

      def event_name
        @event_name ||= event_params.dig(:attributes, :event_name)
      end

      def timestamp
        @timestamp ||= Time.zone.parse(event_params.dig(:attributes, :timestamp))
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
