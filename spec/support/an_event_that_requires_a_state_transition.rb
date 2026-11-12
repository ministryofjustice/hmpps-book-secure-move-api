# frozen_string_literal: true

RSpec.shared_examples 'an event that requires a state transition' do |transition, permitted_states|
  describe 'state transition validation' do
    subject(:generic_event) { build(factory, eventable:, skip_state_transition_validation: false) }

    let(:factory) { described_class.name.demodulize.underscore.prepend('event_').to_sym }
    let(:eventable_type) { described_class.eventable_types.first }
    let(:eventable) { create(eventable_type.underscore.to_sym, state) }

    all_states = described_class.eventable_types.first == 'Move' ? Move.statuses.keys : Journey.states.keys

    all_states.each do |current_state|
      context "when the eventable is #{current_state}" do
        let(:state) { current_state.to_sym }

        if permitted_states.include?(current_state)
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }

          it 'explains why the event was rejected' do
            generic_event.validate
            expect(generic_event.errors[:eventable]).to contain_exactly("cannot #{transition} when #{current_state}")
          end
        end
      end

      context "when the eventable is #{current_state} and the validation is skipped" do
        subject(:generic_event) { build(factory, eventable:) }

        let(:state) { current_state.to_sym }

        it { is_expected.to be_valid }
      end
    end
  end
end
