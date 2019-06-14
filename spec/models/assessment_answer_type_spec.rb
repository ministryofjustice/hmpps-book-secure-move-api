# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssessmentAnswerType do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_inclusion_of(:category).in_array(described_class.categories.values) }
end
