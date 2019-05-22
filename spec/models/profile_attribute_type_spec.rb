# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileAttributeType do
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:user_type) }
end
