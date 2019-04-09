# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  subject(:profile) { described_class.new }

  it { is_expected.to belong_to(:person) }
end
