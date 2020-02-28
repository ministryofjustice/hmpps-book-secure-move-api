# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrisonTransferReason do
  subject(:reason) { build(:prison_transfer_reason) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:key) }
end
