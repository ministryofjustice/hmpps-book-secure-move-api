# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvents::CommonParamsValidator do
  subject(:params_validator) { described_class.new(event_params, event_relationships) }

  let(:event_params) do
    {
      'attributes' => {
        'event_type' => event_type,
        'occurred_at' => occurred_at,
        'recorded_at' => recorded_at,
      },
    }
  end
  let(:event_relationships) do
    {
      'eventable' => {
        'data' => {
          'id' => 'wibble',
          'type' => eventable_type,
        },
      },
    }
  end

  let(:occurred_at) { Time.zone.now.iso8601 }
  let(:recorded_at) { Time.zone.now.iso8601 }
  let(:event_type) { 'MoveCancel' }
  let(:eventable_type) { 'moves' }

  it { is_expected.to be_valid }

  context 'with incorrect eventable_type' do
    let(:eventable_type) { 'movess' }

    it { is_expected.not_to be_valid }
  end

  context 'with incorrect event_type' do
    let(:event_type) { 'FooBar' }

    it { is_expected.not_to be_valid }
  end

  context 'with incorrect non iso8601 occurred_at' do
    let(:occurred_at) { '2019/01/01' }

    it { is_expected.not_to be_valid }
  end

  context 'with incorrect non iso8601 recorded_at' do
    let(:recorded_at) { '2019/01/01' }

    it { is_expected.not_to be_valid }
  end
end
