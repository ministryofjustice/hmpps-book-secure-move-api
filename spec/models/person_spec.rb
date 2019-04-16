# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  it { is_expected.to have_many(:profiles) }
  it { is_expected.to have_many(:moves) }
end
