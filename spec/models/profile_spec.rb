# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:person) }

  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:surname) }
  it { is_expected.to validate_presence_of(:forenames) }
end
