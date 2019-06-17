# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentQuestion do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_inclusion_of(:category).in_array(described_class.categories.values) }
end
