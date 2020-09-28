# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GenericEventsController do
  events = %w[
    move_accept
    move_approve
    move_cancel
    move_collection_by_escort
    move_complete
    move_lockout
    move_lodging_end
    move_lodging_start
    move_notify_premises_of_arrival_in_30_mins
    move_notify_premises_of_eta
    move_notify_premises_of_expected_collection_time
    move_operation_safeguard
    move_operation_tornado
    move_redirect
    move_reject
    move_start
  ].each do |event|
    it_behaves_like 'a generic event endpoint', "event_#{event}", event.camelize do
      let(:eventable_id) { create(:move).id }
      let(:eventable_type) { 'moves' }
    end
  end
end
