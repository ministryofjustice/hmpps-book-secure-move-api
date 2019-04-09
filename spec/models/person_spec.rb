# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  subject(:person) { described_class.new }

  it { is_expected.to have_many(:profiles) }
end
