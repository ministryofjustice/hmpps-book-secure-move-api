# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  events = %w[
    journey_admit_through_outer_gate
    journey_arrive_at_outer_gate
    journey_cancel
    journey_complete
    journey_create
    journey_exit_through_outer_gate
    journey_handover_to_destination
    journey_lockout
    journey_lodging
    journey_person_leave_vehicle
    journey_ready_to_exit
    journey_reject
    journey_start
    journey_uncancel
    journey_uncomplete
    journey_update
  ].each do |event|
    it_behaves_like 'a generic event endpoint', "event_#{event}", event.camelize do
      let(:eventable_id) { create(:journey).id }
      let(:eventable_type) { 'journeys' }
    end
  end
end
