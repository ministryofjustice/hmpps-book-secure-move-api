# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileAttributeType do
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_inclusion_of(:category).in_array(described_class.categories.values) }
  it { is_expected.to validate_inclusion_of(:user_type).in_array(described_class.user_types.values) }
end
