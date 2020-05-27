# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveEvent do
  subject(:move_event) { build(:move_event) }

  it { expect(described_class).to be < Event }

  describe 'to_location' do
    it { expect(move_event.to_location).not_to be nil }
    it { expect(move_event.to_location).to be_a Location }
  end
end
