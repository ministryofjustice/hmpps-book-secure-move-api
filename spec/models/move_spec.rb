# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  subject(:move) { described_class.new }

  it 'works' do
    expect(move).to be_present
  end
end
