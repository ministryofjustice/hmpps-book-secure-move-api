# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QueueDeterminer do
  let(:target) do
    # anonymous class to test concern against
    Class.new(ApplicationJob) {
      include QueueDeterminer

      def self.name
        'TestValidationClass'
      end
    }.new(params)
  end
  let(:params) { {} }

  describe 'move_queue_priority' do
    subject { target.move_queue_priority(move) }

    context 'with move today' do
      let(:move) { build(:move, date: Time.zone.today) }

      it { is_expected.to be(:notifications_high) }
    end

    context 'with move tomorrow' do
      let(:move) { build(:move, date: Time.zone.tomorrow) }

      it { is_expected.to be(:notifications_medium) }
    end

    context 'with move next week' do
      let(:move) { build(:move, date: Time.zone.today + 7) }

      it { is_expected.to be(:notifications_low) }
    end

    context 'with move last week' do
      let(:move) { build(:move, date: Time.zone.today - 7) }

      it { is_expected.to be(:notifications_low) }
    end

    context 'with nil move' do
      let(:move) { nil }

      it { is_expected.to be(:notifications_low) }
    end
  end

  describe 'queue_as' do
    subject { target.queue_name }

    context 'when queue_as is not specified' do
      it { is_expected.to eql('notifications_medium') }
    end

    context 'when queue_as is specified' do
      let(:params) { { queue_as: :foo_queue } }

      it { is_expected.to eql('foo_queue') }
    end
  end
end
