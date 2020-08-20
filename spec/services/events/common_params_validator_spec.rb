# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::CommonParamsValidator do
  subject(:params_validator) { described_class.new(event_params) }

  let(:event_params) do
    {
      'attributes' => {
        'event_type' => event_type,
        'client_timestamp' => client_timestamp,
      },
    }
  end

  let(:client_timestamp) { Time.zone.now.iso8601 }
  let(:event_type) { 'MoveCancelV2' }

  it { is_expected.to be_valid }

  context 'with incorrect event_type' do
    let(:event_type) { 'FooBar' }

    it { is_expected.not_to be_valid }
  end

  context 'with incorrect client_timestamp' do
    let(:client_timestamp) { '2019/01/01' }

    it { is_expected.not_to be_valid }
  end
end
